import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/common/helper/ui/app_copy.dart';
import 'package:writeread_admin_panel/common/widgets/info_tip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/common/helper/navigator/app_navigator.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_locale_content.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_state.dart';

/// Confirms discarding unsaved locale metadata before switching language.
/// Returns true if the switch may proceed.
Future<bool> confirmLocaleSwitchIfNeeded(
  BuildContext context,
  ComicLocaleCubit cubit,
) async {
  if (!cubit.state.hasUnsavedMetadata) return true;
  final discard = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: const Text(
        'You have unsaved title, description, or category changes for '
        'this language. Switch and discard them?',
      ),
      actions: [
        TextButton(
          onPressed: () => AppNavigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => AppNavigator.pop(ctx, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return discard == true;
}

Color readinessColor(LocaleReadiness readiness) {
  return switch (readiness) {
    LocaleReadiness.ready => const Color(0xFF2E7D32),
    LocaleReadiness.partial => const Color(0xFFEF6C00),
    LocaleReadiness.missing => const Color(0xFF757575),
  };
}

/// Overview of all languages for one comic (Missing / Partial / Ready).
/// Tapping a cell switches the language tab (with unsaved-metadata guard).
class ComicLocaleMatrix extends StatelessWidget {
  const ComicLocaleMatrix({super.key, required this.comic});

  final ComicEntity comic;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComicLocaleCubit, ComicLocaleState>(
      buildWhen: (prev, curr) =>
          prev.selectedLocale != curr.selectedLocale ||
          prev.hasUnsavedMetadata != curr.hasUnsavedMetadata,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Localization overview',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              const InfoTip(message: AppCopy.localeEditorTip),
              const SizedBox(height: 8),
              Text(
                'Tap a language to edit it. Green = Ready, orange = Partial, '
                'grey = Missing.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in AppLocales.codes)
                    _LocaleMatrixCell(
                      code: code,
                      readiness: comic.readinessFor(code),
                      selected: state.selectedLocale == code,
                      onTap: () async {
                        final cubit = context.read<ComicLocaleCubit>();
                        if (code == cubit.state.selectedLocale) return;
                        final ok =
                            await confirmLocaleSwitchIfNeeded(context, cubit);
                        if (!ok || !context.mounted) return;
                        cubit.selectLocale(code);
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocaleMatrixCell extends StatelessWidget {
  const _LocaleMatrixCell({
    required this.code,
    required this.readiness,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final LocaleReadiness readiness;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = readinessColor(readiness);
    final label = switch (readiness) {
      LocaleReadiness.ready => 'Ready',
      LocaleReadiness.partial => 'Partial',
      LocaleReadiness.missing => 'Missing',
    };

    return Material(
      color: color.withValues(alpha: selected ? 0.22 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? color : color.withValues(alpha: 0.45),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocales.nativeName(code),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
