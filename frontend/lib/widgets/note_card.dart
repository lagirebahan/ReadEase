import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final dynamic note;
  final AppTheme theme;

  const NoteCard({super.key, required this.note, required this.theme});

  @override
  Widget build(BuildContext context) {
    final rawPath = (note['image_path'] ?? '').toString();

    final imageUrl = rawPath.isNotEmpty && !rawPath.startsWith('http')
        ? '${AppConfig.baseUrl}$rawPath'
        : rawPath;

    final hasImage = imageUrl.isNotEmpty;

    final noteTitle = (note['title'] ?? 'Untitled').toString();
    final noteGroup = (note['note_group'] ?? 'Uncategorized').toString();
    final extractedText = (note['extracted_text'] ?? '').toString().trim();
    final lastUpdated = _formatDate(note['updated_at']);
    final isPinned = note['is_pinned'] == 1 || note['is_pinned'] == true;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: theme.borderColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: theme.accentColor,
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            noteGroup,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isPinned) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.push_pin,
                            size: 13, color: theme.accentColor),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    noteTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme
                        .baseTextStyle(theme.primaryTextColor)
                        .copyWith(
                            fontSize: 13, fontWeight: FontWeight.w700),
                  ),

                  if (extractedText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        extractedText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .baseTextStyle(
                                theme.primaryTextColor.withValues(alpha: 0.55))
                            .copyWith(fontSize: 11, height: 1.4),
                      ),
                    ),
                  ] else
                    const Spacer(),

                  const SizedBox(height: 4),

                  Text(
                    lastUpdated,
                    style: theme
                        .baseTextStyle(
                            theme.primaryTextColor.withValues(alpha: 0.4))
                        .copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: theme.borderColor.withValues(alpha: 0.5),
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 36,
            color: theme.primaryTextColor.withValues(alpha: 0.3)),
      ),
    );
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().isEmpty) return '';
    try {
      final dt = DateTime.parse(rawDate.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
