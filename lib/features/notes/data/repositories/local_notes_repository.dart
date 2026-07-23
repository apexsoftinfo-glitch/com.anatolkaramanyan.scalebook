import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/notes_repository.dart';

class LocalNotesRepository implements NotesRepository {
  Future<Directory> get _dataDir async {
    final docs = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(docs.path, 'scalebook_data', 'notes'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  @override
  Future<List<Note>> getNotes() async {
    final directory = await _dataDir;
    final entities = await directory.list().toList();
    final files = entities.whereType<File>().where((f) => f.path.endsWith('.json'));

    final noteFutures = files.map((file) async {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return Note.fromJson(json);
      } catch (e) {
        return null;
      }
    });

    final results = await Future.wait(noteFutures);
    final notes = results.whereType<Note>().toList();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  @override
  Future<void> addNote(Note note) async {
    await updateNote(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    final directory = await _dataDir;
    final file = File(p.join(directory.path, '${note.id}.json'));
    await file.writeAsString(jsonEncode(note.toJson()));
  }

  @override
  Future<void> deleteNote(String id) async {
    final directory = await _dataDir;
    final file = File(p.join(directory.path, '$id.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
