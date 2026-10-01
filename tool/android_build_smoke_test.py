"""Compile the Android plugin in an isolated host and check its JVM bytecode.

Run with a Gradle installation compatible with the selected AGP version:
  python3 tool/android_build_smoke_test.py --gradle /path/to/gradle \
    --agp 9.1.0 --built-in-kotlin true \
    --android-sdk /path/to/android-sdk --flutter-sdk /path/to/flutter

For external Kotlin, also pass --kotlin-version (for example 2.2.20 on AGP 8.1.0).
"""

import argparse
from io import BytesIO
import json
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gradle", required=True)
    parser.add_argument("--agp", required=True)
    parser.add_argument("--kotlin-version")
    parser.add_argument("--built-in-kotlin", choices=("true", "false"))
    parser.add_argument("--android-sdk", type=Path, required=True)
    parser.add_argument("--flutter-sdk", type=Path, required=True)
    args = parser.parse_args()

    flutter_jar = args.flutter_sdk.resolve() / "bin/cache/artifacts/engine/android-arm64/flutter.jar"
    if not flutter_jar.is_file():
        parser.error(f"Flutter Android embedding not found: {flutter_jar}")
    legacy_kotlin = int(args.agp.split(".")[0]) < 9 or args.built_in_kotlin == "false"
    if legacy_kotlin and not args.kotlin_version:
        parser.error("Legacy Kotlin requires --kotlin-version")

    with tempfile.TemporaryDirectory(prefix="motion-sensors-android-") as directory:
        host = Path(directory)
        shutil.copytree(Path(__file__).resolve().parents[1] / "android", host / "plugin",
                        ignore=shutil.ignore_patterns(".gradle", "build", "local.properties"))
        (host / "settings.gradle").write_text("rootProject.name = 'android-smoke-test'\ninclude ':plugin'\n")
        classpaths = f'classpath "com.android.tools.build:gradle:{args.agp}"\n'
        if args.kotlin_version:
            classpaths += f'classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:{args.kotlin_version}"\n'
        # JSON string escaping is also valid for these Groovy file-path literals.
        (host / "build.gradle").write_text(
            "buildscript {\nrepositories { google(); mavenCentral() }\n"
            f"dependencies {{ {classpaths} }}\n}}\n"
            "allprojects { repositories { google(); mavenCentral() } }\n"
            "project(':plugin') {\nafterEvaluate {\ndependencies {\n"
            f"compileOnly files({json.dumps(str(flutter_jar))})\n"
            'compileOnly "androidx.annotation:annotation:1.5.0"\n'
            "}\n}\n}\n"
        )
        (host / "local.properties").write_text(f"sdk.dir={args.android_sdk.resolve()}\n")
        properties = "android.useAndroidX=true\n"
        if args.built_in_kotlin:
            properties += f"android.builtInKotlin={args.built_in_kotlin}\n"
        if args.built_in_kotlin == "false":
            properties += "android.newDsl=false\n"
        (host / "gradle.properties").write_text(properties)
        subprocess.run([args.gradle, "--no-daemon", "--console=plain", "--max-workers=2",
                        "-p", str(host), ":plugin:assembleDebug"], check=True)

        aar = host / "plugin/build/outputs/aar/plugin-debug.aar"
        with zipfile.ZipFile(aar) as archive:
            with zipfile.ZipFile(BytesIO(archive.read("classes.jar"))) as classes:
                bytecode = classes.read("finaldev/motion_sensors/MotionSensorsPlugin.class")
        major_version = struct.unpack(">H", bytecode[6:8])[0]
        assert major_version == 52, f"Expected Java 8 bytecode, got class version {major_version}"
        print(f"PASS: AGP {args.agp}, built-in Kotlin {args.built_in_kotlin or 'default'}, "
              "MotionSensorsPlugin compiled to Java 8 bytecode")


if __name__ == "__main__":
    main()
