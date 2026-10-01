# example

Example app for the `dchs_motion_sensors` plugin.

## Getting Started

The example requires Flutter 3.47 or newer and Dart 3.13 or newer, matching plugin version 3.0.0.
Its Android host uses AGP 9.1.1, Gradle 9.3.1 and Kotlin 2.4.20 with built-in Kotlin enabled.
`android.newDsl=false` is retained for compatibility with the current Flutter Gradle plugin.

Useful commands:

- `flutter devices`
- `flutter run -d <device-id>`
- `flutter analyze`
- `flutter test`
- `flutter build ios --simulator`

## Physical Android device verification

Connect an Android phone with USB debugging enabled and allow app installation over USB.
On devices that restrict USB installations, confirm the installer prompt or enable the corresponding developer option.

```bash
flutter test integration_test/motion_sensors_test.dart -d <device-id>
flutter run -d <device-id>
```

The integration tests collect finite readings from each available physical sensor, await native interval changes,
record event delivery at slow and fast settings, exercise the 1 / 30 / 60 FPS selectors,
and close the example to verify subscription cleanup. Missing optional sensors are skipped; an accelerometer is required.
The requested sensor frequency is a hardware-dependent sampling interval, not a guaranteed screen refresh rate.

## iOS Swift Package Manager

The iOS host uses Swift Package Manager and targets iOS 15 or newer, matching the current Flutter toolchain.

If you need to regenerate the iOS host app with the current Flutter template, remove `ios/` and run `flutter create --platforms=ios --project-name example .`.
