import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const sensorNames = [
    'accelerometer',
    'gyroscope',
    'magnetometer',
    'user_accelerometer',
    'orientation',
    'absolute_orientation',
    'screen_orientation',
  ];
  final cancelled = <String>{};
  final listened = <String>{};
  Completer<bool>? availability;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    cancelled.clear();
    listened.clear();
    availability = null;
    messenger.setMockMethodCallHandler(
      const MethodChannel('motion_sensors/method'),
      (call) async => call.method == 'isSensorAvailable'
          ? (availability == null ? true : await availability!.future)
          : null,
    );
    for (final name in sensorNames) {
      messenger.setMockMethodCallHandler(
        MethodChannel('motion_sensors/$name'),
        (call) async {
          if (call.method == 'listen') listened.add(name);
          if (call.method == 'cancel') cancelled.add(name);
          return null;
        },
      );
    }
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('motion_sensors/method'),
      null,
    );
    for (final name in sensorNames) {
      messenger.setMockMethodCallHandler(
        MethodChannel('motion_sensors/$name'),
        null,
      );
    }
  });

  testWidgets('renders motion sensors example', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Update Interval'), findsOneWidget);
    expect(find.text('Accelerometer'), findsOneWidget);
    expect(find.text('Magnetometer'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('disposal cancels every sensor subscription', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(cancelled, sensorNames.toSet());
  });

  testWidgets('late availability does not subscribe after disposal', (
    tester,
  ) async {
    availability = Completer<bool>();
    await tester.pumpWidget(const MyApp());
    await tester.pumpWidget(const SizedBox.shrink());
    availability!.complete(true);
    await tester.pump();

    expect(listened, isNot(contains('orientation')));
  });
}
