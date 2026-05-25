import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// const String {AppConfig.baseUrl} = 'http://192.168.1.4:3001';

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
      await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
        headers: {'Content-Type': 'application/json'},
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
          // Pin toggle
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned
                  ? theme.accentColor
                  : theme.primaryTextColor.withValues(alpha: 0.5),
            ),
            onPressed: () async {
              setState(() => _isPinned = !_isPinned);
              await http.put(
                Uri.parse('${AppConfig.baseUrl}/api/notes/${widget.noteId}'),
                headers: {'Content-Type': 'application/json'},
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
          // Edit / Save
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
          // Group badge
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.borderColor),

          // Text area
          Expanded(
            child: _isEditing
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      style: theme.baseTextStyle(theme.primaryTextColor),
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
                            : theme.primaryTextColor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}