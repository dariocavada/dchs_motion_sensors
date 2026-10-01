import 'dart:async';
import 'dart:convert';

import 'package:dchs_motion_sensors/dchs_motion_sensors.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.reportData = <String, dynamic>{};

  testWidgets('native sensors emit finite readings and acknowledge intervals', (
    tester,
  ) async {
    final streams = <int, Stream<dynamic>>{
      MotionSensors.TYPE_ACCELEROMETER: motionSensors.accelerometer,
      MotionSensors.TYPE_MAGNETIC_FIELD: motionSensors.magnetometer,
      MotionSensors.TYPE_GYROSCOPE: motionSensors.gyroscope,
      MotionSensors.TYPE_USER_ACCELEROMETER: motionSensors.userAccelerometer,
      MotionSensors.TYPE_ORIENTATION: motionSensors.orientation,
      MotionSensors.TYPE_ABSOLUTE_ORIENTATION:
          motionSensors.absoluteOrientation,
    };
    final counts = <String, int>{};
    final samples = <String, List<double>>{};
    final errors = <Object>[];
    final subscriptions = <StreamSubscription<dynamic>>[];
    final available = <int>[];

    try {
      for (final entry in streams.entries) {
        if (!await motionSensors.isSensorAvailable(entry.key)) continue;
        available.add(entry.key);
        final name = entry.key.toString();
        counts[name] = 0;
        subscriptions.add(
          entry.value.listen((dynamic event) {
            final List<double> values = switch (event) {
              AccelerometerEvent() => [event.x, event.y, event.z],
              MagnetometerEvent() => [event.x, event.y, event.z],
              GyroscopeEvent() => [event.x, event.y, event.z],
              UserAccelerometerEvent() => [event.x, event.y, event.z],
              OrientationEvent() => [event.yaw, event.pitch, event.roll],
              AbsoluteOrientationEvent() => [
                event.yaw,
                event.pitch,
                event.roll,
              ],
              _ => throw StateError('Unexpected sensor event: $event'),
            };
            counts[name] = counts[name]! + 1;
            samples[name] = values;
          }, onError: errors.add),
        );
      }
      expect(available, contains(MotionSensors.TYPE_ACCELEROMETER));
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(errors, isEmpty);
      for (final sensor in available) {
        expect(counts[sensor.toString()], greaterThan(1));
        expect(samples[sensor.toString()]!.every((v) => v.isFinite), isTrue);
      }
      binding.reportData!['sensorCounts'] = counts;
      binding.reportData!['sensorSamples'] = samples;
      debugPrint('SENSOR_READINGS ${jsonEncode(binding.reportData)}');

      for (final sensor in available) {
        await motionSensors
            .setSensorUpdateInterval(sensor, 1000000)
            .timeout(const Duration(seconds: 3));
      }
      final before = Map<String, int>.from(counts);
      await Future<void>.delayed(const Duration(seconds: 3));
      final slowCounts = <String, int>{
        for (final sensor in available)
          sensor.toString():
              counts[sensor.toString()]! - before[sensor.toString()]!,
      };
      expect(slowCounts.values.every((count) => count > 0), isTrue);
      binding.reportData!['slowSensorCounts'] = slowCounts;

      for (final sensor in available) {
        await motionSensors
            .setSensorUpdateInterval(sensor, 16666)
            .timeout(const Duration(seconds: 3));
      }
      final beforeFast = Map<String, int>.from(counts);
      await Future<void>.delayed(const Duration(seconds: 2));
      final fastCounts = <String, int>{
        for (final sensor in available)
          sensor.toString():
              counts[sensor.toString()]! - beforeFast[sensor.toString()]!,
      };
      // SensorManager documents samplingPeriodUs as a hint: delivery may be
      // faster or slower. Verify acknowledgement and continued event delivery.
      expect(fastCounts.values.every((count) => count > 0), isTrue);
      expect(errors, isEmpty);
      binding.reportData!['fastSensorCounts'] = fastCounts;
      debugPrint('SENSOR_INTERVALS ${jsonEncode(binding.reportData)}');
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    }
  });

  testWidgets('example displays sensors and changes all interval controls', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Motion Sensors'), findsOneWidget);
    expect(find.text('Accelerometer'), findsOneWidget);

    for (final value in [1, 2, 3]) {
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is Radio<int> && widget.value == value,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
        value,
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
