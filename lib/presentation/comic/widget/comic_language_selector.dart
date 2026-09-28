import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writeread_admin_panel/core/locale/app_locales.dart';
import 'package:writeread_admin_panel/domain/comic/entity/comic_entity.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_cubit.dart';
import 'package:writeread_admin_panel/presentation/comic/bloc/comic_locale_state.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/comic_locale_matrix.dart';
import 'package:writeread_admin_panel/presentation/comic/widget/locale_readiness_chip.dart';

class ComicLanguageSelector extends StatefulWidget {
  const ComicLanguageSelector({super.key, required this.comic});

  final ComicEntity comic;

  @override
  State<ComicLanguageSelector> createState() => _ComicLanguageSelectorState();
}

class _ComicLanguageSelectorState extends State<ComicLanguageSelector> {
  /// Bumped when a switch is cancelled so the dropdown remounts on the
  /// previous [selectedLocale] (FormField keeps the rejected value otherwise).
  int _dropdownGeneration = 0;

  Future<void> _onLocaleChanged(String? value) async {
    if (value == null) return;
    final cubit = context.read<ComicLocaleCubit>();
    if (value == cubit.state.selectedLocale) return;

    final ok = await confirmLocaleSwitchIfNeeded(context, cubit);
    if (!mounted) return;
    if (!ok) {
      setState(() => _dropdownGeneration++);
      return;
    }

    cubit.selectLocale(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComicLocaleCubit, ComicLocaleState>(
      buildWhen: (prev, curr) =>
          prev.selectedLocale != curr.selectedLocale ||
          prev.hasUnsavedMetadata != curr.hasUnsavedMetadata,
      builder: (context, state) {
        final selected = state.selectedLocale;
        final readiness = widget.comic.readinessFor(selected);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('$selected-$_dropdownGeneration'),
                  initialValue: selected,
                  decoration: InputDecoration(
                    labelText: 'Language',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    helperText: state.hasUnsavedMetadata
                        ? 'Unsaved metadata — save before switching'
                        : null,
                    helperStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AppLocales.english,
                      child: Text(AppLocales.nativeName(AppLocales.english)),
                    ),
                    ...AppLocales.contentLocaleCodes.map(
                      (code) => DropdownMenuItem(
                        value: code,
                        child: Text(
                          '${AppLocales.nativeName(code)} ($code)',
                        ),
                      ),
                    ),
                  ],
                  onChanged: _onLocaleChanged,
                ),
              ),
              const SizedBox(width: 12),
              LocaleReadinessChip(readiness: readiness),
            ],
          ),
        );
      },
    );
  }
}
