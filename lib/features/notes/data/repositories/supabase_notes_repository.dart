import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/notes_repository.dart';

class SupabaseNotesRepository implements NotesRepository {
  SupabaseClient get _client => Supabase.instance.client;
  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Użytkownik nie jest zalogowany'); // L10N
    return user.id;
  }

  @override
  Future<List<Note>> getNotes() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('notes')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Note.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addNote(Note note) async {
    await _client.from('notes').insert({
      ...note.toJson(),
      'user_id': _userId,
    });
  }

  @override
  Future<void> updateNote(Note note) async {
    await _client.from('notes').update({
      'title': note.title,
      'content': note.content,
      'image_urls': note.imageUrls,
      'link': note.link,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', note.id);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
