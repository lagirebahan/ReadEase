import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/models/note.dart';
import 'package:frontend/pages/reader_page.dart';
import 'package:frontend/services/note_service.dart';
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
  String? _error;

  Note? _lastEdited;
  List<Note> _pinned = [];
  List<Note> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try{
      final notes = await NoteService.getNotes();
 
      // Most recently updated = last edited
      final sorted = [...notes]
        ..sort((a, b) => (b.updatedAt ?? DateTime(0))
            .compareTo(a.updatedAt ?? DateTime(0)));
 
      setState(() {
        _lastEdited = sorted.isNotEmpty ? sorted.first : null;
        _pinned = notes.where((n) => n.isPinned).take(4).toList();
        _recent = sorted.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          noteId: note.noteId,
          initialTitle: note.title,
          initialText: note.extractedText,
          noteGroup: note.noteGroup,
          isPinned: note.isPinned,
        ),
      ),
    ).then((_) => _loadNotes()); // refresh on return
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
              onTap: onSeeAll,
              child: Text('See all >', style: TextStyle(color: theme.accentColor, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueSection(AppTheme theme) {
    final note = _lastEdited!;
    final imageUrl = '${AppConfig.baseUrl}${note.imagePath}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openNote(note);
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.primaryTextColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.primaryTextColor.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: theme.primaryTextColor.withValues(alpha: 0.15),
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
                          .baseTextStyle(theme.primaryTextColor.withValues(alpha: 0.5))
                          .copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note.title,
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
                      '${note.noteGroup}  ·  ${note.updatedAt}',
                      style: theme
                          .baseTextStyle(theme.primaryTextColor.withValues(alpha: 0.5))
                          .copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.primaryTextColor.withValues(alpha: 0.5),
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
                color: theme.surfaceBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: theme.primaryTextColor, size: 26),
                  const SizedBox(height: 6),
                  Text(label,
                      style: theme
                          .baseTextStyle(theme.primaryTextColor)
                          .copyWith(fontSize: 11),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
 
  Widget _buildNoteGrid(List<Note> notes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () => _openNote(note),
          child: NoteCard(note: note.toDisplayMap(), theme: context.read<AppTheme>()),
        );
      },
    );
  }
 
  /// Pinned notes grid (max 4, 2-column)
  // Widget _buildPinnedSection(AppTheme theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader(theme, '📌 Pinned'),
  //       const SizedBox(height: 12),
  //       GridView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         itemCount: _pinned.length,
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           mainAxisSpacing: 12,
  //           crossAxisSpacing: 12,
  //           childAspectRatio: 0.65,
  //         ),
  //         itemBuilder: (context, index) {
  //           return NoteCard(note: _pinned[index], theme: theme);
  //         },
  //       ),
  //     ],
  //   );
  // }
 
  // /// Recent notes grid
  // Widget _buildRecentSection(AppTheme theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader(
  //         theme,
  //         'Recent Notes',
  //         onSeeAll: () {
  //           // TODO: navigate to Notes page / all-notes view
  //         },
  //       ),
  //       const SizedBox(height: 12),
  //       if (_recent.isEmpty)
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  //           child: Center(
  //             child: Text(
  //               'No recent notes.',
  //               style: theme.baseTextStyle(Colors.black),
  //             ),
  //           ),
  //         )
  //       else
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           itemCount: _recent.length,
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 2,
  //             mainAxisSpacing: 12,
  //             crossAxisSpacing: 12,
  //             childAspectRatio: 0.65,
  //           ),
  //           itemBuilder: (context, index) {
  //             return NoteCard(note: _recent[index], theme: theme);
  //           },
  //         ),
  //     ],
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
 
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
 
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Could not connect to server',
                style: theme.baseTextStyle(theme.primaryTextColor)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadNotes, child: const Text('Retry')),
          ],
        ),
      );
    }
 
    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
 
            if (_lastEdited != null) ...[
              _buildContinueSection(theme),
              const SizedBox(height: 24),
            ],
 
            _buildQuickActions(theme),
            const SizedBox(height: 24),
 
            if (_pinned.isNotEmpty) ...[
              _buildSectionHeader(theme, '📌 Pinned'),
              const SizedBox(height: 12),
              _buildNoteGrid(_pinned),
              const SizedBox(height: 24),
            ],
 
            _buildSectionHeader(theme, 'Recent Notes',
                onSeeAll: widget.onSeeAll),
            const SizedBox(height: 12),
            if (_recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                child: Center(
                  child: Text('No notes yet.',
                      style: theme.baseTextStyle(
                          theme.primaryTextColor.withOpacity(0.5))),
                ),
              )
            else
              _buildNoteGrid(_recent),
          ],
        ),
      ),
    );
  }
}