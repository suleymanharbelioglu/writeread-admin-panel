import 'package:flutter/material.dart';
import 'package:writeread_admin_panel/domain/comment/entity/comment.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.onDeletePressed,
    this.deleting = false,
  });

  final CommentEntity comment;
  final VoidCallback onDeletePressed;
  final bool deleting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final created = comment.createdAt;
    final dateLabel =
        '${created.year.toString().padLeft(4, '0')}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} '
        '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

    final location = (comment.chapterId == null || comment.chapterId!.isEmpty)
        ? 'Comic comment'
        : (comment.chapterName != null && comment.chapterName!.isNotEmpty
            ? comment.chapterName!
            : 'Chapter ${comment.chapterId}');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  backgroundImage: comment.userAvatarUrl != null &&
                          comment.userAvatarUrl!.isNotEmpty
                      ? NetworkImage(comment.userAvatarUrl!)
                      : null,
                  child: (comment.userAvatarUrl == null ||
                          comment.userAvatarUrl!.isEmpty)
                      ? Text(
                          comment.userName.isNotEmpty
                              ? comment.userName.characters.first.toUpperCase()
                              : '?',
                          style: theme.textTheme.labelLarge,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              comment.userName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (comment.isSpoiler)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Spoiler',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: Icons.schedule,
                            label: dateLabel,
                          ),
                          _MetaChip(
                            icon: Icons.place_outlined,
                            label: location,
                          ),
                          _MetaChip(
                            icon: Icons.person_outline,
                            label: comment.userId,
                            monospace: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete comment',
                  onPressed: deleting ? null : onDeletePressed,
                  icon: deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              comment.text,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.monospace = false,
  });

  final IconData icon;
  final String label;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: (monospace
                    ? theme.textTheme.labelSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      )
                    : theme.textTheme.labelSmall)
                ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

