import 'package:flutter/material.dart';
import 'screens/prediction_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DeliveryTimeApp());
}

class DeliveryTimeApp extends StatelessWidget {
  const DeliveryTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Time Predictor',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        body: PredictionPage(),
      ),
    );
  }
}
