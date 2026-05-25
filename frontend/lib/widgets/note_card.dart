import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class NoteCard extends StatelessWidget{
  final dynamic note;
  final AppTheme theme;
  
  const NoteCard({super.key, required this.note, required this.theme});

  @override
  Widget build(BuildContext context) {
    final imageUrl = note['image_path'] ?? '';
    final noteTitle = note['title'] ?? '';
    final noteGroup = note['note_group'] ?? 'Uncategorized';
    final lastUpdated = _formatDate(note['updated_at']);

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: imageUrl.isNotEmpty ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.borderColor,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ) : Container(
                color: theme.borderColor,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              )
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, 
                    vertical: 2
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.5)
                    ),
                  ),
                  child: Text(
                    noteGroup,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
                const SizedBox(height: 6),
                Text(noteTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(
                  'Last Updated: $lastUpdated',
                  style: theme.baseTextStyle(
                    theme.primaryTextColor.withValues(alpha: 0.5)).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null || rawDate.toString().isEmpty) return 'Unknown';
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
      return rawDate.toString();
    }
  }

}
