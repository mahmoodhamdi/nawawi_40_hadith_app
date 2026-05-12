import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/markdown_style.dart';
import '../cubit/language_cubit.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';

/// Inline notes editor for a single hadith. Sits between the citation
/// card and the explanation card on the details screen.
///
/// Two visual states:
///   - **Empty / collapsed**: subtle "Add note" hint with a pencil icon
///   - **Filled**: markdown-rendered note with edit + delete actions
///
/// Tapping "edit" opens a multi-line text dialog. Saving writes through
/// the NotesCubit, which persists to SharedPreferences.
class HadithNoteCard extends StatelessWidget {
  final int hadithIndex;

  const HadithNoteCard({super.key, required this.hadithIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        final note = state.noteFor(hadithIndex);
        final hasNote = note.isNotEmpty;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: theme.cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.note_alt_outlined,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.yourNotes,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (hasNote) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n.editNote,
                        onPressed: () => _editNote(context, note),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: l10n.deleteNote,
                        onPressed: () => _confirmDelete(context),
                      ),
                    ],
                  ],
                ),
                if (!hasNote) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _editNote(context, ''),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add,
                              color: theme.colorScheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.addNote,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: note,
                    styleSheet: l10n.isArabic
                        ? getArabicMarkdownStyle(context, baseFontSize: 14)
                        : getHadithMarkdownStyle(context, baseFontSize: 14),
                    selectable: true,
                    softLineBreak: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editNote(BuildContext context, String existing) async {
    final l10n = AppLocalizations.read(context);
    final languageState = context.read<LanguageCubit>().state;
    final controller = TextEditingController(text: existing);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: languageState.textDirection,
        child: AlertDialog(
          title: Text(existing.isEmpty ? l10n.addNote : l10n.editNote),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: controller,
              maxLines: 10,
              minLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.noteHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || result == null) return;
    await context.read<NotesCubit>().setNote(hadithIndex, result);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmAction),
        content: Text(l10n.deleteNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<NotesCubit>().removeNote(hadithIndex);
    }
  }
}
