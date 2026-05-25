import 'dart:convert';
import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/config.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/pages/reader_page.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Uint8List? _imageBytes;
  bool _isCropping = false;
  bool _isScanning = false;
  final CropController _cropController = CropController();

  // ── Pick image from gallery ────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isCropping = true;
    });
  }

  // ── After crop: OCR → temp-save → show save dialog ────────────────────────
  Future<void> _onCropped(Uint8List croppedBytes) async {
    setState(() {
      _isCropping = false;
      _isScanning = true;
    });

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          croppedBytes,
          filename: 'cropped.png',
        ))
        ..fields['title'] = '__temp__'
        ..fields['note_group'] = 'Uncategorized'
        ..fields['is_pinned'] = '0';

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (!mounted) return;

      setState(() => _isScanning = false);

      final note = data['note'] as Map<String, dynamic>;

      // Show save dialog; delete note if user discards
      final saved = await _showSaveSheet(note);
      if (!saved) {
        await http.delete(Uri.parse('${AppConfig.baseUrl}/api/notes/${note['note_id']}'));
        if(!mounted) return;
        setState(() => _imageBytes = null);
      }
    } catch (e) {
      setState(() => _isScanning = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }
  }

  // ── Save bottom sheet ──────────────────────────────────────────────────────
  // Returns true if the user saved (and we navigated away), false if discarded.
  Future<bool> _showSaveSheet(Map<String, dynamic> note) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaveSheet(note: note, baseUrl: AppConfig.baseUrl),
    );
    return result ?? false;
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

    // ── Crop view ────────────────────────────────────────────────────────────
    if (_isCropping && _imageBytes != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Crop Image',
              style: TextStyle(color: Colors.white, fontFamily: 'Georgia')),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: Crop(
                image: _imageBytes!,
                controller: _cropController,
                onCropped: (croppedData) {
    _onCropped(croppedData);
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _cropController.crop(),
                    child: const Text('Crop & Scan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Scanning overlay ─────────────────────────────────────────────────────
    if (_isScanning) {
      return Scaffold(
        backgroundColor: theme.baseBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.accentColor),
              const SizedBox(height: 20),
              Text('Scanning…',
                  style: TextStyle(
                      color: theme.primaryTextColor,
                      fontSize: 18,
                      fontFamily: 'Georgia')),
            ],
          ),
        ),
      );
    }

    // ── Default: pick image ───────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        title: Text('Upload',
            style: TextStyle(
                color: theme.primaryTextColor,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w600)),
        backgroundColor: theme.baseBg,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustrated upload area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: theme.surfaceBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 56, color: theme.accentColor),
                      const SizedBox(height: 16),
                      Text('Tap to pick an image',
                          style: TextStyle(
                              color: theme.primaryTextColor,
                              fontSize: 16,
                              fontFamily: 'Georgia')),
                      const SizedBox(height: 6),
                      Text('Supports JPG, PNG',
                          style: TextStyle(
                              color: theme.primaryTextColor.withOpacity(0.45),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _pickImage,
                  icon:
                      const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text('Choose from Gallery',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Save bottom sheet ─────────────────────────────────────────────────────────

class _SaveSheet extends StatefulWidget {
  final Map<String, dynamic> note;
  final String baseUrl;
  const _SaveSheet({required this.note, required this.baseUrl});

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  final _titleController = TextEditingController();
  String? _selectedGroup;   // null = Ungrouped
  String? _newGroupName;
  bool _isPinned = false;
  bool _isCreatingGroup = false;
  List<String> _groups = [];
  bool _loadingGroups = true;
  bool _isSaving = false;

  final _newGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final res =
          await http.get(Uri.parse('${widget.baseUrl}/api/groups'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _groups = data.cast<String>()
            ..remove('Uncategorized')
            ..remove('__temp__');
          _loadingGroups = false;
        });
      }
    } catch (_) {
      setState(() => _loadingGroups = false);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isSaving = true);

    final group = _isCreatingGroup && _newGroupController.text.trim().isNotEmpty
        ? _newGroupController.text.trim()
        : (_selectedGroup ?? 'Uncategorized');

    try {
      await http.put(
        Uri.parse('${widget.baseUrl}/api/notes/${widget.note['note_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'extracted_text': widget.note['extracted_text'],
          'note_group': group,
          'is_pinned': _isPinned ? 1 : 0,
        }),
      );

      if (!mounted) return;

      // Navigate to reader, removing the save sheet and upload page
      Navigator.of(context).pop(true); // close sheet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReaderPage(
            noteId: widget.note['note_id'] as int,
            initialTitle: title,
            initialText: widget.note['extracted_text'] as String? ?? '',
            noteGroup: group,
            isPinned: _isPinned,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<AppTheme>();
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: mq.viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Text('Save Note',
                style: TextStyle(
                    color: theme.primaryTextColor,
                    fontSize: 22,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Add a title and organise your note.',
                style: TextStyle(
                    color: theme.primaryTextColor.withOpacity(0.5),
                    fontSize: 14)),
            const SizedBox(height: 24),

            // ── Title ──────────────────────────────────────────────────────
            Text('Title',
                style: TextStyle(
                    color: theme.primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: TextStyle(color: theme.primaryTextColor),
              decoration: InputDecoration(
                hintText: 'e.g. Lecture 3 Notes',
                hintStyle: TextStyle(
                    color: theme.primaryTextColor.withOpacity(0.35)),
                filled: true,
                fillColor: theme.baseBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.accentColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Group ──────────────────────────────────────────────────────
            Text('Group',
                style: TextStyle(
                    color: theme.primaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),

            if (_loadingGroups)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(color: theme.accentColor),
              )
            else
              _buildGroupPicker(theme),

            // New group text field (shown when "New Group" is selected)
            if (_isCreatingGroup) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _newGroupController,
                style: TextStyle(color: theme.primaryTextColor),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Group name…',
                  hintStyle: TextStyle(
                      color: theme.primaryTextColor.withOpacity(0.35)),
                  filled: true,
                  fillColor: theme.baseBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: theme.accentColor, width: 2),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Pin toggle ─────────────────────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _isPinned = !_isPinned),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.baseBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPinned
                        ? theme.accentColor
                        : theme.borderColor,
                    width: _isPinned ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: _isPinned
                          ? theme.accentColor
                          : theme.primaryTextColor.withOpacity(0.5),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text('Pin this note',
                        style: TextStyle(
                            color: theme.primaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Switch(
                      value: _isPinned,
                      onChanged: (v) => setState(() => _isPinned = v),
                      activeColor: theme.accentColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Action buttons ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.borderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Discard',
                        style: TextStyle(
                            color: theme.primaryTextColor.withOpacity(0.7),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save & Read',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupPicker(AppTheme theme) {
    // Fixed-height scrollable list of chips
    final options = <_GroupOption>[
      const _GroupOption(label: 'Ungrouped', value: null, isNew: false),
      ..._groups.map((g) => _GroupOption(label: g, value: g, isNew: false)),
      const _GroupOption(label: '+ New Group', value: '__new__', isNew: true),
    ];

    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: theme.baseBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: options.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: theme.borderColor),
        itemBuilder: (_, i) {
          final opt = options[i];
          final isSelected = opt.isNew
              ? _isCreatingGroup
              : (!_isCreatingGroup && _selectedGroup == opt.value);

          return InkWell(
            onTap: () {
              if (opt.isNew) {
                setState(() {
                  _isCreatingGroup = true;
                  _selectedGroup = null;
                });
              } else {
                setState(() {
                  _isCreatingGroup = false;
                  _selectedGroup = opt.value;
                });
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        color: opt.isNew
                            ? theme.accentColor
                            : theme.primaryTextColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 18, color: theme.accentColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupOption {
  final String label;
  final String? value;
  final bool isNew;
  const _GroupOption(
      {required this.label, required this.value, required this.isNew});
}