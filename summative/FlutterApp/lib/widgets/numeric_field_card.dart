import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

/// A numeric input field, wrapped in a [SectionCard].
class NumericFieldCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hint;
  final TextEditingController controller;
  final bool allowDecimal;

  const NumericFieldCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.controller,
    this.allowDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal, signed: true),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.pillTrack,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
