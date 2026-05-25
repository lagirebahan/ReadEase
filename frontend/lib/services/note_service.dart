import 'dart:convert';
import 'package:frontend/config/config.dart';
import 'package:frontend/models/note.dart';
import 'package:http/http.dart' as http;

class NoteService {
  static final String _base = AppConfig.apiBase;

  // GET /api/notes  or  /api/notes?tag=groupname
  static Future<List<Note>> getNotes({String? tag}) async {
    final uri = tag != null && tag != 'All'
        ? Uri.parse('$_base/notes?tag=${Uri.encodeComponent(tag)}')
        : Uri.parse('$_base/notes');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load notes: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body);
    return data.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/notes/:id
  static Future<Note> getNoteById(int id) async {
    final res = await http.get(Uri.parse('$_base/notes/$id'));
    if (res.statusCode != 200) {
      throw Exception('Note not found');
    }
    return Note.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // GET /api/groups
  static Future<List<String>> getGroups() async {
    final res = await http.get(Uri.parse('$_base/groups'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load groups: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.cast<String>();
  }

  // PUT /api/notes/:id
  static Future<void> updateNote({
    required int id,
    required String title,
    required String extractedText,
    required String noteGroup,
    required bool isPinned,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/notes/$id'),
      headers: {'Content-Type': 'application/json'},
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

  // DELETE /api/notes/:id
  static Future<void> deleteNote(int id) async {
    final res = await http.delete(Uri.parse('$_base/notes/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete note: ${res.statusCode}');
    }
  }
}