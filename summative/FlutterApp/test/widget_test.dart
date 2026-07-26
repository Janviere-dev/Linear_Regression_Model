import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:delivery_time_app/main.dart';

void main() {
  testWidgets('Prediction page renders all required elements', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryTimeApp());

    // Title and Predict button are present.
    expect(find.text('Delivery Time Predictor'), findsOneWidget);
    expect(find.text('Predict'), findsOneWidget);

    // One text field per numeric input (age, rating, 4 coordinates).
    expect(find.byType(TextField), findsNWidgets(6));
  });
}
