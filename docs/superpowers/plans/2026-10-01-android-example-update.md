# Android example update Implementation Plan

> **For agentic workers:** Implement inline with superpowers:executing-plans; use one independent review at the end.

**Goal:** Update the plugin and example dependencies, keep the AGP 9 fix, and run the actual example on the connected Android phone.

**Architecture:** The plugin inherits Android tooling from its host and retains the tested legacy branch. The example becomes the built-in Kotlin host and carries an integration test for real sensor events and interval controls.

**Tech Stack:** Flutter 3.47.5 / Dart 3.13.4, AGP 9.1.1, Gradle 9.3.1, host Kotlin 2.4.20, Android 15.

**Spec:** User request in this conversation: update components and example, fix the reported issue, and test the example on the connected physical device.

## Global Constraints

- Preserve existing user changes to analysis options and `.serena/`.
- Prepare 3.0.0 and require Flutter 3.47 / Dart 3.13 in plugin and example, as subsequently authorized by the user.
- Keep AGP 8 / Kotlin 2.2.20+ and Java 8 plugin bytecode; document dropping Kotlin 1.8 as a breaking change.
- Use `android.builtInKotlin=true`; keep `android.newDsl=false` for the installed Flutter SDK.
- Changes remain local; no publish, push or commit is requested.

## Review Focus

- Root dependency constraints match the newly declared Flutter 3.47 minimum.
- AGP 8 and AGP 9 opt-out hosts supply Kotlin 2.2.20+ and use compilerOptions.
- Real sensor events, rather than default zero text, demonstrate the device test.
- Interval method calls must complete; changing the selector must keep streams alive.
- Teardown must cancel example subscriptions before the widget is disposed.

### Task 1: Update dependencies and Android host

**Files:** `pubspec.yaml`, `example/pubspec.yaml`, `example/android/{settings.gradle,gradle.properties,app/build.gradle,gradle/wrapper/gradle-wrapper.properties}`, README and changelog.
**Interfaces:** Consume the existing conditional plugin Gradle configuration; produce a host with built-in Kotlin enabled.

- [ ] Record baseline `flutter test`, `flutter analyze`, and `flutter pub outdated` results.
- [ ] Update vector_math to 2.4.3 in root and example; update example flutter_lints to 6.0.0 and cupertino_icons to 2.0.0; add SDK integration_test.
- [ ] Update the example to the tooling listed above; remove module KGP application and use compilerOptions.
- [ ] Run pub resolution, analysis and widget tests; expect success.

### Task 2: Verify actual sensor behavior

**Files:** `example/integration_test/motion_sensors_test.dart`, and only implementation files needed to fix failures exposed by these tests.
**Interfaces:** Consume real plugin streams and example controls; produce test evidence for native registration, sensor events, interval acknowledgements and disposal.

- [ ] Write and run a real-device integration test for finite readings from each available sensor, interval acknowledgements and the 1/30/60 FPS controls; record any failure before a fix.
- [ ] Correct only confirmed failures, adding focused widget coverage where applicable.
- [ ] Repeat affected tests; expect all checks to pass on the physical Android phone.

### Task 3: Validate and document

**Files:** `docs/android-device-validation.md`, README, CHANGELOG, this plan.
**Interfaces:** Consume test and build outputs; produce reproducible commands and a clear record of what was physically verified.

- [ ] Compile legacy and modern Android smoke tests and a release example APK; expect Java 8 plugin bytecode and successful builds.
- [ ] Launch the regular example on the phone and inspect the visible sensor screen and a changed update interval.
- [ ] Run final analysis/test/diff checks and independent review; document actual results and any limits.
