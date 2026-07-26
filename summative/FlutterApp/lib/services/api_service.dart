import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_request.dart';

/// Talks to the deployed FastAPI backend.
class ApiService {
  static const String baseUrl = 'https://delivery-time-prediction-api.onrender.com';

  /// Calls POST /predict. Returns the predicted minutes on success.
  /// Throws an [ApiException] with a human-readable message on failure.
  static Future<double> predictDeliveryTime(DeliveryRequest request) async {
    final uri = Uri.parse('$baseUrl/predict');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['predicted_delivery_time_minutes'] as num).toDouble();
    }

    if (response.statusCode == 422) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final details = data['detail'] as List<dynamic>;
      final messages = details.map((d) {
        final field = (d['loc'] as List).last;
        return '$field: ${d['msg']}';
      }).join('\n');
      throw ApiException(messages);
    }

    throw ApiException('Server error (${response.statusCode}). Please try again.');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
