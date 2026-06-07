import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/models/note.dart';
import 'package:frontend/pages/reader_page.dart';
import 'package:frontend/pages/upload_page.dart';
import 'package:frontend/services/note_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/note_card.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/services/auth_service.dart';

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try{
      final notes = await NoteService.getNotes();
 
      final sorted = [...notes]
        ..sort((a, b) => (b.updatedAt ?? DateTime(0))
            .compareTo(a.updatedAt ?? DateTime(0)));
 
      if (!mounted) return;
      setState(() {
        _lastEdited = sorted.isNotEmpty ? sorted.first : null;
        _pinned = notes.where((n) => n.isPinned).take(4).toList();
        _recent = sorted.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
    ).then((_) => _loadNotes());
  }

  Future<void> _onNewNote() async {
    final theme = context.read<AppTheme>();
    final titleController = TextEditingController();
    String selectedFolder = 'Uncategorized';
    List<String> folders = [];

    try {
      folders = await NoteService.getFolders();
    } catch (_) {}

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: theme.surfaceBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('New Note',
              style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                style: TextStyle(color: theme.primaryTextColor),
                decoration: InputDecoration(
                  hintText: 'Give it a name...',
                  hintStyle: TextStyle(color: theme.primaryTextColor.withOpacity(0.4)),
                  filled: true,
                  fillColor: theme.baseBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Folder', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.6), fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.baseBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.borderColor),
                ),
                child: DropdownButton<String>(
                  value: selectedFolder,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: theme.surfaceBg,
                  style: TextStyle(color: theme.primaryTextColor, fontSize: 14),
                  items: [
                    DropdownMenuItem(value: 'Uncategorized', child: Text('Uncategorized', style: TextStyle(color: theme.primaryTextColor))),
                    ...folders.map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(color: theme.primaryTextColor)))),
                  ],
                  onChanged: (v) => setDialogState(() => selectedFolder = v ?? 'Uncategorized'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final title = titleController.text.trim().isEmpty ? 'Untitled' : titleController.text.trim();

    try {
      final user = await AuthService.getCurrentUser();
      final res = await http.post(
        Uri.parse('${AppConfig.apiBase}/notes'),
        headers: {
          'Content-Type': 'application/json',
          if (user != null) 'x-user-id': user['user_id']!,
        },
        body: jsonEncode({'title': title, 'note_group': selectedFolder, 'is_pinned': false}),
      );
      if (!mounted) return;
      final data = jsonDecode(res.body);
      final note = data['note'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderPage(
            noteId: note['note_id'] as int,
            initialTitle: title,
            initialText: '',
            noteGroup: selectedFolder,
            isPinned: false,
          ),
        ),
      ).then((_) => _loadNotes());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _onNewFolder() async {
    final theme = context.read<AppTheme>();
    final folderController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('New Folder',
            style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
        content: TextField(
          controller: folderController,
          autofocus: true,
          style: TextStyle(color: theme.primaryTextColor),
          decoration: InputDecoration(
            hintText: 'Folder name...',
            hintStyle: TextStyle(color: theme.primaryTextColor.withOpacity(0.4)),
            filled: true,
            fillColor: theme.baseBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final folderName = folderController.text.trim();
    if (folderName.isEmpty) return;

    try {
      await NoteService.createFolder(folderName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Folder "$folderName" created!'),
          backgroundColor: Colors.green[700],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red[700]),
      );
    }
  }

  void _onScanDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UploadPage()),
    ).then((_) => _loadNotes());
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

  Widget _buildQuickActions(AppTheme theme) {
    final actions = [
      (Icons.add_rounded, 'New Note', _onNewNote),
      (Icons.create_new_folder_outlined, 'New Folder', _onNewFolder),
      (Icons.document_scanner_outlined, 'Scan', _onScanDocument),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) {
          final (icon, label, callback) = action;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: callback,
            child: Ink(
              width: 90,
              height: 82,
              decoration: BoxDecoration(
                color: theme.surfaceBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: theme.accentColor, size: 26),
                  const SizedBox(height: 6),
                  Text(label,
                      style: theme
                          .baseTextStyle(theme.primaryTextColor)
                          .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }).toList(),
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
        childAspectRatio: 0.58,
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