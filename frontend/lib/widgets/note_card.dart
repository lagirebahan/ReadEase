import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class NoteCard extends StatelessWidget{
  final dynamic note;
  final AppTheme theme;
  
  const NoteCard({super.key, required this.note, required this.theme});

  @override
  Widget build(BuildContext context) {
    final imageUrl = note['image'] ?? '';
    final noteTitle = note['note_title'] ?? '';
    final noteGroup = note['note_group'] ?? 'Uncategorized';
    final lastUpdated = note['updated_at'] ?? '';

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
                errorBuilder: (_, _, _) => Container(
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

  String _formatDate(dynamic lastUpdated) {
    final date = 'test';
    return date;
  }

}
