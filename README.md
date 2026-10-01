# motion_sensors

Flutter plugin for accessing the Android and iOS accelerometer, gyroscope, magnetometer and orientation sensors.
Updated version from https://github.com/zesage/motion_sensors

## Getting Started

Version 3.0.0 requires Flutter `>=3.47.0` and Dart `>=3.13.0` and supports Android builds with AGP 9 and built-in Kotlin enabled.
This is a breaking update from the Flutter 3.41 / Dart 3.11 minimums in version 2.0.2.

To use this plugin, add `dchs_motion_sensors` as a [dependency in your pubspec.yaml
file](https://flutter.io/platform-plugins/).

```yaml
dependencies:
  dchs_motion_sensors: ^3.0.0
```

Import to your project.

``` dart
import 'package:dchs_motion_sensors/dchs_motion_sensors.dart';

motionSensors.magnetometer.listen((MagnetometerEvent event) {
    print(event);
});

```

## Android build compatibility

The plugin uses the Android Gradle Plugin (AGP) and Kotlin versions supplied by the host app.
With AGP 9 or newer, it uses built-in Kotlin by default and does not apply `kotlin-android`.
With AGP 8, it applies the host's Kotlin plugin. Use Kotlin 2.2.20 or newer, compatible with your AGP and Gradle versions.
Kotlin 1.8 is no longer supported because the plugin now uses `kotlin.compilerOptions` for every Android host.
Java and Kotlin plugin bytecode continue to target JVM 1.8.

AGP 9 apps that explicitly set `android.builtInKotlin=false` also use the host's Kotlin plugin.
These apps must configure `android.newDsl=false` and supply a compatible Kotlin plugin, as described in the
[Android migration guide](https://developer.android.com/build/migrate-to-built-in-kotlin#opt-out).

To verify compilation without changing the example app, run the isolated Android smoke test with JDK 17 or newer:

```bash
python3 tool/android_build_smoke_test.py \
  --gradle /path/to/gradle-9.3.1/bin/gradle \
  --agp 9.1.0 --built-in-kotlin true \
  --android-sdk /path/to/android-sdk --flutter-sdk /path/to/flutter
```

For the legacy path, select a Gradle version compatible with AGP 8.1.0 and pass
`--agp 8.1.0 --kotlin-version 2.2.20`. For AGP 9 with built-in Kotlin disabled, pass
`--agp 9.1.0 --built-in-kotlin false --kotlin-version 2.2.20`.
Omitting `--built-in-kotlin` verifies AGP's default behavior.
The test builds the plugin's AAR using the installed Flutter Android embedding and verifies that
`MotionSensorsPlugin` is present with Java 8 bytecode. It does not test sensor behavior on a device.

The example uses AGP 9.1.1, Gradle 9.3.1 and Kotlin 2.4.20 with `android.builtInKotlin=true`.
It keeps `android.newDsl=false` because the current Flutter Gradle plugin still requires the legacy Android DSL.
See [example/README.md](example/README.md) for physical-device sensor tests.

## Example iOS With Swift Package Manager

The example app under `example/` can be regenerated with the current Flutter iOS template, which wires plugins through Swift Package Manager instead of CocoaPods.

From `example/` run:

```bash
rm -rf ios
flutter create --platforms=ios --project-name example .
flutter build ios --simulator
```

After regeneration, the Podfile and Pods references disappear from the iOS host app and the Xcode project uses the local FlutterGeneratedPluginSwiftPackage package instead.

## Upgrade Note

If you are upgrading from an older release of this plugin and your iOS app or example was created from a CocoaPods-based Flutter template, regenerate the `ios/` host project with a current Flutter SDK before testing or publishing the plugin update on iOS.

For version 3.0.0, use Flutter 3.47 or newer. If your app still uses the old iOS host template, rerun
`flutter create --platforms=ios .` inside the app or example directory so the Xcode project picks up the Swift Package Manager wiring.
