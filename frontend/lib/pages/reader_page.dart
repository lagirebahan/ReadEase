import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/note_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/auth_service.dart';

class ReaderPage extends StatefulWidget {
  final int noteId;
  final String initialTitle;
  final String initialText;
  final String noteGroup;
  final bool isPinned;

  const ReaderPage({
    super.key,
    required this.noteId,
    required this.initialTitle,
    required this.initialText,
    required this.noteGroup,
    required this.isPinned,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late String _title;
  late String _text;
  late String _group;
  late bool _isPinned;
  bool _isEditing = false;
  bool _isSaving = false;

  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _title = widget.initialTitle;
    _text = widget.initialText;
    _group = widget.noteGroup;
    _isPinned = widget.isPinned;
    _textController = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveEdits() async {
    setState(() => _isSaving = true);
    try {
      final user = await AuthService.getCurrentUser();
      await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
        headers: {
          'Content-Type': 'application/json',
          if (user != null) 'x-user-id': user['user_id']!,
        },
        body: jsonEncode({
          'title': _title,
          'extracted_text': _textController.text,
          'note_group': _group,
          'is_pinned': _isPinned ? 1 : 0,
        }),
      );
      setState(() {
        _text = _textController.text;
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _confirmDeleteNote() async {
    final theme = context.read<AppTheme>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete Note',
            style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
        content: Text(
          'Are you sure you want to delete this note?',
          style: TextStyle(color: theme.primaryTextColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final user = await AuthService.getCurrentUser();
      final res = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
        headers: {
          if (user != null) 'x-user-id': user['user_id']!,
        },
      );
      if (res.statusCode != 200) {
        throw Exception('Failed to delete note');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Note deleted!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete note: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _changeFolder() async {
    final theme = context.read<AppTheme>();
    List<String> folders = [];
    bool loading = true;

    final newFolder = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (loading) {
            NoteService.getFolders().then((list) {
              setDialogState(() {
                folders = list;
                loading = false;
              });
            }).catchError((err) {
              setDialogState(() {
                loading = false;
              });
            });
          }

          return AlertDialog(
            backgroundColor: theme.surfaceBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text('Select Folder',
                style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
            content: loading
                ? const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: Icon(Icons.folder_open_outlined, color: theme.accentColor),
                          title: Text('Uncategorized', style: TextStyle(color: theme.primaryTextColor)),
                          onTap: () => Navigator.pop(ctx, 'Uncategorized'),
                        ),
                        const Divider(),
                        ...folders.map((folder) => ListTile(
                              leading: Icon(Icons.folder_outlined, color: theme.accentColor),
                              title: Text(folder, style: TextStyle(color: theme.primaryTextColor)),
                              onTap: () => Navigator.pop(ctx, folder),
                            )),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.create_new_folder_outlined, color: theme.accentColor),
                          title: Text('New Folder...',
                              style: TextStyle(color: theme.accentColor, fontWeight: FontWeight.bold)),
                          onTap: () async {
                            final newName = await _showCreateFolderDialog(ctx);
                            if (newName != null && newName.isNotEmpty) {
                              Navigator.pop(ctx, newName);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
              ),
            ],
          );
        },
      ),
    );

    if (newFolder == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final user = await AuthService.getCurrentUser();
      await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
        headers: {
          'Content-Type': 'application/json',
          if (user != null) 'x-user-id': user['user_id']!,
        },
        body: jsonEncode({
          'title': _title,
          'extracted_text': _text,
          'note_group': newFolder,
          'is_pinned': _isPinned ? 1 : 0,
        }),
      );
      setState(() {
        _group = newFolder;
        _isSaving = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Note moved to "$newFolder"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to move folder: $e')),
      );
    }
  }

  Future<String?> _showCreateFolderDialog(BuildContext context) async {
    final theme = context.read<AppTheme>();
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('New Folder',
            style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
        content: TextField(
          controller: controller,
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.accentColor),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                try {
                  await NoteService.createFolder(name);
                  Navigator.pop(ctx, name);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red[700]),
                  );
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

    return Scaffold(
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        backgroundColor: theme.surfaceBg,
        elevation: 0,
        title: Text(
          _title,
          style: TextStyle(
            color: theme.primaryTextColor,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.primaryTextColor.withValues(alpha: 0.7),
            ),
            onPressed: _confirmDeleteNote,
            tooltip: 'Delete note',
          ),
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned
                  ? theme.accentColor
                  : theme.primaryTextColor.withValues(alpha: 0.5),
            ),
            onPressed: () async {
              setState(() => _isPinned = !_isPinned);
              final user = await AuthService.getCurrentUser();
              await http.put(
                Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
                headers: {
                  'Content-Type': 'application/json',
                  if (user != null) 'x-user-id': user['user_id']!,
                },
                body: jsonEncode({
                  'title': _title,
                  'extracted_text': _text,
                  'note_group': _group,
                  'is_pinned': _isPinned ? 1 : 0,
                }),
              );
            },
            tooltip: _isPinned ? 'Unpin' : 'Pin',
          ),
          if (_isEditing)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.check_rounded),
                    color: Colors.green,
                    onPressed: _saveEdits,
                    tooltip: 'Save',
                  )
          else
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: theme.primaryTextColor.withValues(alpha: 0.7)),
              onPressed: () => setState(() {
                _isEditing = true;
                _textController.text = _text;
              }),
              tooltip: 'Edit text',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.borderColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: _changeFolder,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 14, color: theme.accentColor),
                        const SizedBox(width: 5),
                        Text(_group,
                            style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down,
                            size: 16, color: theme.accentColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.borderColor),

          Expanded(
            child: _isEditing
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: theme.baseTextStyle(
                        theme.useAccentForText ? theme.accentColor : theme.primaryTextColor,
                      ),
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Extracted text…',
                        hintStyle: TextStyle(
                            color:
                                theme.primaryTextColor.withValues(alpha: 0.35)),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: SelectableText(
                      _text.isEmpty
                          ? 'No text was extracted from this image.'
                          : _text,
                      style: theme.baseTextStyle(
                        _text.isEmpty
                            ? theme.primaryTextColor.withValues(alpha: 0.4)
                            : (theme.useAccentForText ? theme.accentColor : theme.primaryTextColor),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}