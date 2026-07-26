import 'package:flutter/material.dart';

/// Shown when validation fails or the API call errors required
/// "display area" for an error message.
class ErrorCard extends StatelessWidget {
  final String message;

  const ErrorCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3B9B9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Something went wrong',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFB43C3C))),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(fontSize: 14, color: Color(0xFFB43C3C))),
        ],
      ),
    );
  }
}
