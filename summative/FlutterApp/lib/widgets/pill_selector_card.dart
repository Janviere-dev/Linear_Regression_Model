import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class PillSelectorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final List<String> labels;
  final String? selected;
  final ValueChanged<String> onSelected;

  const PillSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.pillTrack,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(options.length, (i) {
            final isSelected = options[i] == selected;
            return GestureDetector(
              onTap: () => onSelected(options[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
