import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';

class LocaleReadinessChip extends StatelessWidget {
  const LocaleReadinessChip({super.key, required this.readiness});

  final LocaleReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final (label, Color color) = switch (readiness) {
      LocaleReadiness.ready => ('Ready', const Color(0xFF2E7D32)),
      LocaleReadiness.partial => ('Partial', const Color(0xFFEF6C00)),
      LocaleReadiness.missing => ('Missing', const Color(0xFF757575)),
    };

    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
