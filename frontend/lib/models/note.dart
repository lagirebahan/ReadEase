class Note {
  final int noteId;
  final String title;
  final String imagePath;
  final String extractedText;
  final String noteGroup;
  final bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.noteId,
    required this.title,
    required this.imagePath,
    required this.extractedText,
    required this.noteGroup,
    required this.isPinned,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteId: json['note_id'] as int,
      title: json['title'] as String? ?? '',
      imagePath: json['image_path'] as String? ?? '',
      extractedText: json['extracted_text'] as String? ?? '',
      noteGroup: json['note_group'] as String? ?? 'Uncategorized',
      isPinned: (json['is_pinned'] == 1 || json['is_pinned'] == true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toDisplayMap() => {
        'note_id': noteId,
        'title': title,
        'image_path': imagePath,
        'extracted_text': extractedText,
        'note_group': noteGroup,
        'is_pinned': isPinned ? 1 : 0,
        'updated_at': updatedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'note_id': noteId,
        'title': title,
        'image_path': imagePath,
        'extracted_text': extractedText,
        'note_group': noteGroup,
        'is_pinned': isPinned ? 1 : 0,
      };
}