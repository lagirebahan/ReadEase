import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:frontend/models/note.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static final String _base = AppConfig.apiBase;

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('auth_user_id');
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'x-user-id': userId.toString(),
    };
  }

  static Future<List<Note>> getNotes({String? tag}) async {
    final uri = tag != null && tag != 'All'
        ? Uri.parse('$_base/notes?tag=${Uri.encodeComponent(tag)}')
        : Uri.parse('$_base/notes');

    final headers = await _getHeaders();
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load notes: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Note> getNoteById(int id) async {
    final headers = await _getHeaders();
    final res = await http.get(Uri.parse('$_base/notes/$id'), headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Note not found');
    }
    return Note.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<List<String>> getGroups() async {
    final headers = await _getHeaders();
    final res = await http.get(Uri.parse('$_base/groups'), headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load groups: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.cast<String>();
  }

  static Future<List<String>> getFolders() async {
    final headers = await _getHeaders();
    final res = await http.get(Uri.parse('$_base/folders'), headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to load folders');
    final List data = jsonDecode(res.body);
    return data.cast<String>();
  }

  static Future<void> createFolder(String name) async {
    final headers = await _getHeaders();
    final res = await http.post(
      Uri.parse('$_base/folders'),
      headers: headers,
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Failed to create folder');
    }
  }

  static Future<void> deleteFolder(String name) async {
    final headers = await _getHeaders();
    final res = await http.delete(
      Uri.parse('$_base/folders/${Uri.encodeComponent(name)}'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to delete folder');
  }

  static Future<void> updateNote({
    required int id,
    required String title,
    required String extractedText,
    required String noteGroup,
    required bool isPinned,
  }) async {
    final headers = await _getHeaders();
    final res = await http.put(
      Uri.parse('$_base/notes/$id'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'extracted_text': extractedText,
        'note_group': noteGroup,
        'is_pinned': isPinned ? 1 : 0,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update note: ${res.statusCode}');
    }
  }

  static Future<void> deleteNote(int id) async {
    final headers = await _getHeaders();
    final res = await http.delete(Uri.parse('$_base/notes/$id'), headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.statusCode}');
    }
  }
}