import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/note_card.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
  final VoidCallback? onSeeAll; 
  const HomePage({super.key, required this.onSeeAll});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  bool _isLoading = true;
  Map<String, dynamic>? _lastEdited;
  List<dynamic> _pinned = [];
  List<dynamic> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    //dummy
    final lastEdited = {
      'note_title': 'Biology Notes',
      'note_group': 'School',
      'image': 'https://picsum.photos/200',
      'updated_at': 'May 20, 2026',
      'is_pinned': true,
    };
    final pinned = [
      {
        'note_title': 'Biology Notes',
        'note_group': 'School',
        'image':
            'https://picsum.photos/200',
        'updated_at': 'May 20, 2026',
        'is_pinned': 'true,'
      },
      {
        'note_title': 'Math Summary',
        'note_group': 'Lecture',
        'image':
            'https://picsum.photos/201',
        'updated_at': 'May 19, 2026',
        'is_pinned': 'true,'
      },
      {
        'note_title': 'Project Ideas',
        'note_group': 'Personal',
        'image':
            'https://picsum.photos/204',
        'updated_at': 'May 10, 2026',
        'is_pinned': 'true,'
      },
    ];

    final recent = [
      {
        'note_title': 'Biology Notes',
        'note_group': 'School',
        'image': 'https://picsum.photos/200',
        'updated_at': 'May 20, 2026',
        'is_pinned': true,
      },
      {
        'note_title': 'Math Summary',
        'note_group': 'Lecture',
        'image': 'https://picsum.photos/201',
        'updated_at': 'May 19, 2026',
        'is_pinned': false,
      },
      {
        'note_title': 'Chemistry Review',
        'note_group': 'School',
        'image': 'https://picsum.photos/202',
        'updated_at': 'May 17, 2026',
        'is_pinned': false,
      },
    ];

    setState(() {
      _lastEdited = lastEdited;
      _pinned = pinned.take(4).toList();
      _recent = recent;
      _isLoading = false;
    });
  }

  
  void _onNewNote() {
    // TODO: navigate to new note screen
  }
 
  void _onNewFolder() {
    // TODO: show new folder dialog
  }
 
  void _onScanDocument() {
    // TODO: open camera / document scanner
  }
 
  void _onImport() {
    // TODO: open file picker
  }

  Widget _buildSectionHeader(
    AppTheme theme,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme
                .baseTextStyle(theme.primaryTextColor)
                .copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: widget.onSeeAll,
              child: Text('See all >', style: TextStyle(color: theme.primaryTextColor,)),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueSection(AppTheme theme) {
    final note = _lastEdited!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: open the note
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.primaryTextColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryTextColor.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  note['image'] as String,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: theme.primaryTextColor.withOpacity(0.15),
                    child: Icon(Icons.note, color: theme.primaryTextColor),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue where you left off',
                      style: theme
                          .baseTextStyle(Colors.black)
                          .copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note['note_title'] as String,
                      style: theme
                          .baseTextStyle(theme.primaryTextColor)
                          .copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${note['note_group']}  ·  ${note['updated_at']}',
                      style: theme
                          .baseTextStyle(Colors.black)
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  /// Horizontal row of quick-action buttons
  Widget _buildQuickActions(AppTheme theme) {
    final actions = [
      (Icons.add_rounded, 'New Note', _onNewNote),
      (Icons.create_new_folder_outlined, 'New Folder', _onNewFolder),
      (Icons.document_scanner_outlined, 'Scan', _onScanDocument),
      (Icons.upload_file_outlined, 'Import', _onImport),
    ];
 
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final (icon, label, callback) = actions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: callback,
            child: Ink(
              width: 80,
              decoration: BoxDecoration(
                color: theme.surfaceBg, //theme.cardColor
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black ?? Colors.grey.shade200, //theme.dividerColor
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: theme.primaryTextColor, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: theme
                        .baseTextStyle(theme.primaryTextColor)
                        .copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
 
  /// Pinned notes grid (max 4, 2-column)
  Widget _buildPinnedSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, '📌 Pinned'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _pinned.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            return NoteCard(note: _pinned[index], theme: theme);
          },
        ),
      ],
    );
  }
 
  /// Recent notes grid
  Widget _buildRecentSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Recent Notes',
          onSeeAll: () {
            // TODO: navigate to Notes page / all-notes view
          },
        ),
        const SizedBox(height: 12),
        if (_recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: Text(
                'No recent notes.',
                style: theme.baseTextStyle(Colors.black),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recent.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              return NoteCard(note: _recent[index], theme: theme);
            },
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
 
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
 
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
 
          // ① Continue where you left off
          if (_lastEdited != null) ...[
            _buildContinueSection(theme),
            const SizedBox(height: 24),
          ],
 
          // ② Quick actions
          _buildQuickActions(theme),
          const SizedBox(height: 24),
 
          // ③ Pinned notes (only shown when there are any)
          if (_pinned.isNotEmpty) ...[
            _buildPinnedSection(theme),
            const SizedBox(height: 24),
          ],
 
          // ④ Recent notes
          _buildRecentSection(theme),
        ],
      ),
    );
  }
}