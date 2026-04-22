import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('renders motion sensors example', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Update Interval'), findsOneWidget);
    expect(find.text('Accelerometer'), findsOneWidget);
    expect(find.text('Magnetometer'), findsOneWidget);
  });
}
