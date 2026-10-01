## 3.0.0

### Breaking changes

* require Flutter 3.47 or newer and Dart 3.13 or newer, replacing the previous Flutter 3.41 / Dart 3.11 minimums
* migrate Android Kotlin compiler configuration to `kotlin.compilerOptions`; Kotlin 1.8 hosts are no longer supported
* Android hosts using AGP 8 or disabling built-in Kotlin must supply a compatible Kotlin Gradle Plugin (2.2.20 or newer); the plugin no longer pins its own AGP / Kotlin classpaths
* update `vector_math` to `^2.4.3`

### Fixes and updates

* fix the `kotlin-android` configuration failure on AGP 9 with built-in Kotlin enabled
* apply the host's Kotlin plugin only when built-in Kotlin is unavailable or explicitly disabled
* set the Android namespace directly and keep Java / Kotlin plugin bytecode targeting JVM 1.8
* update the example to AGP 9.1.1, Gradle 9.3.1 and Kotlin 2.4.20, with built-in Kotlin enabled
* update the example's `cupertino_icons` to 2.0.0 and `flutter_lints` to 6.0.0
* update the example's iOS host to the Flutter 3.47 Swift Package Manager wiring and iOS 15 deployment target
* cancel the example's sensor subscriptions on disposal and ignore late orientation availability responses
* complete the native Android / iOS response for `setSensorUpdateInterval` so awaited interval changes no longer hang
* add Android compilation checks, example lifecycle tests and physical-device sensor integration tests

## 2.0.2

* add Swift Package Manager support for iOS
* move the iOS implementation to Swift-only plugin registration
* update the minimum Flutter and Dart SDK versions for SPM support
* iOS consumers should use Flutter 3.41 or newer; older toolchains will not generate the Swift Package Manager-based iOS host correctly
* if you update an existing example or app from the old CocoaPods-based iOS template, regenerate the `ios/` host app with `flutter create --platforms=ios .` before validating the plugin on iOS

## 2.0.1

* updates the plugin to use the new FlutterPlugin API, replacing the deprecated Registrar API, 
which has been completely removed in Flutter 3.28.x. thank you to [BenVae](https://github.com/BenVae)

## 2.0.0

* update build gradle to 8.1.0 
* update kotlin version to 1.8.22
* changed build.gradle file with latest recommendation
* removed gradle.properties, gradle-wrapper.properties and AndroidManifest.xml (deprecated the package definition on that file)
* update the vector_math dependency to the latest version
* update for compatibility to the latest flutter 3.24.3

## 1.1.0

* add support for Android namespace
* bump `compileSdkVersion` to 34

## 1.0.2

* added podspec for ios (bug fixing)

## 1.0.1

* initial release from https://github.com/zesage/motion_sensors
