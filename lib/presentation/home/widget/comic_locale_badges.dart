import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_locale_matrix.dart';

/// Compact per-locale readiness pills for the home catalog grid.
class ComicLocaleBadges extends StatelessWidget {
  const ComicLocaleBadges({super.key, required this.comic});

  final ComicEntity comic;

  @override
  Widget build(BuildContext context) {
    final ready = <String>[];
    final partial = <String>[];
    for (final code in AppLocales.codes) {
      switch (comic.readinessFor(code)) {
        case LocaleReadiness.ready:
          ready.add(code);
        case LocaleReadiness.partial:
          partial.add(code);
        case LocaleReadiness.missing:
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ready.isNotEmpty || partial.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              alignment: WrapAlignment.end,
              children: [
                for (final code in ready) _pill(code, LocaleReadiness.ready),
                for (final code in partial)
                  _pill(code, LocaleReadiness.partial),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '0/${AppLocales.codes.length} ready',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${ready.length} ready · ${partial.length} partial',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(String code, LocaleReadiness readiness) {
    final color = readinessColor(readiness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        code.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
