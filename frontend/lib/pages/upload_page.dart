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
import 'package:frontend/services/auth_service.dart';

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

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _isCropping = true;
    });
  }

  Future<void> _onCropped(Uint8List croppedBytes) async {
    setState(() {
      _isCropping = false;
      _isScanning = true;
    });

    try {
      final user = await AuthService.getCurrentUser();
      final uri = Uri.parse('${AppConfig.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          if (user != null) 'x-user-id': user['user_id']!,
        })
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          croppedBytes,
          filename: 'cropped.png',
        ))
        ..fields['title'] = '__temp__'
        ..fields['note_group'] = 'Uncategorized'
        ..fields['is_pinned'] = '0';

      final response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (!mounted) return;

      setState(() => _isScanning = false);

      final note = data['note'] as Map<String, dynamic>;

      final saved = await _showSaveSheet(note);
      if (!saved) {
        final user = await AuthService.getCurrentUser();
        await http.delete(
          Uri.parse('${AppConfig.baseUrl}/api/notes/${note['note_id']}'),
          headers: {
            if (user != null) 'x-user-id': user['user_id']!,
          },
        );
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

  Future<bool> _showSaveSheet(Map<String, dynamic> note) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaveSheet(note: note, baseUrl: AppConfig.baseUrl),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

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

    return Scaffold(
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        title: Text('Scan Document',
            style: TextStyle(
                color: theme.primaryTextColor,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w600)),
        backgroundColor: theme.baseBg,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.camera),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: theme.accentColor, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt_rounded,
                            size: 56, color: theme.accentColor),
                      ),
                      const SizedBox(height: 18),
                      const Text('Take a Photo',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('Point your camera at a document',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: Divider(color: theme.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or',
                      style: TextStyle(
                          color: theme.primaryTextColor.withValues(alpha: 0.4),
                          fontSize: 13)),
                ),
                Expanded(child: Divider(color: theme.borderColor)),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.surfaceBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.borderColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 28, color: theme.accentColor),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Import from Gallery',
                              style: TextStyle(
                                  color: theme.primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Text('JPG, PNG supported',
                              style: TextStyle(
                                  color: theme.primaryTextColor
                                      .withValues(alpha: 0.45),
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveSheet extends StatefulWidget {
  final Map<String, dynamic> note;
  final String baseUrl;
  const _SaveSheet({required this.note, required this.baseUrl});

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  final _titleController = TextEditingController();
  String? _selectedGroup;
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
      final user = await AuthService.getCurrentUser();
      final res = await http.get(
        Uri.parse('${widget.baseUrl}/api/folders'),
        headers: {
          if (user != null) 'x-user-id': user['user_id']!,
        },
      );
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
      final user = await AuthService.getCurrentUser();
      final res = await http.put(
        Uri.parse('${widget.baseUrl}/api/notes/${widget.note['note_id']}'),
        headers: {
          'Content-Type': 'application/json',
          if (user != null) 'x-user-id': user['user_id']!,
        },
        body: jsonEncode({
          'title': title,
          'extracted_text': widget.note['extracted_text'],
          'note_group': group,
          'is_pinned': _isPinned ? 1 : 0,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
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