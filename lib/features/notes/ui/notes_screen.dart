import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../presentation/cubit/notes_cubit.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../domain/models/note_model.dart';
import 'add_note_screen.dart';
import 'note_detail_screen.dart';
import '../../../../core/design_system/widgets/cutting_mat_background.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).notes), // L10N
        automaticallyImplyLeading: false,
      ),
      body: CuttingMatBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: AppColors.navyBlue),
                decoration: InputDecoration(
                  hintText: S.of(context).searchInNotes,
                  prefixIcon: const Icon(Icons.search, color: AppColors.navyBlue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state.status == NotesStatus.loading && state.notes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.red));
                  }
                  
                  final filteredNotes = state.notes.where((n) {
                    final query = _searchQuery.toLowerCase();
                    return n.title.toLowerCase().contains(query) || 
                           n.content.toLowerCase().contains(query);
                  }).toList();

                  if (filteredNotes.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return _buildNoteCard(context, note);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
        },
        backgroundColor: AppColors.red,
        heroTag: 'notes_fab',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(note: note),
            ),
          );
        },
        onLongPress: () => _confirmDelete(context, note),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (note.imageUrls.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: note.imageUrls.length,
                    itemBuilder: (context, idx) => Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: AppImage(
                        imageUrl: note.imageUrls[idx],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.grey, size: 18),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNoteScreen(note: note),
                            ),
                          );
                        },
                      ),
                      Builder(
                        builder: (buttonContext) => IconButton(
                          icon: const Icon(Icons.ios_share, color: AppColors.grey, size: 18),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          onPressed: () => _shareNoteAsPng(buttonContext, note),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note.content,
                    style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (note.link != null)
                        const Icon(Icons.link, size: 14, color: AppColors.red)
                      else
                        const SizedBox.shrink(),
                      Text(
                        '${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year}',
                        style: const TextStyle(fontSize: 9, color: AppColors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareNoteAsPng(BuildContext context, Note note) async {
    final boundaryKey = GlobalKey();
    final session = context.read<SessionCubit>().state;
    final modelerName = session.displayName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.red)),
    );

    try {
      final widget = _NoteSharePoster(
        note: note,
        boundaryKey: boundaryKey,
        modelerName: modelerName,
      );
      
      // We need to insert the widget into the tree to capture it
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -1000, // Off-screen
          child: Material(child: widget),
        ),
      );
      overlay.insert(overlayEntry);

      // Wait for rendering
      await Future.delayed(const Duration(milliseconds: 500));

      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Nie udało się wyrenderować grafiki');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      overlayEntry.remove();
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/notatka_${note.id}.png').create();
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      final renderObject = context.findRenderObject();
      final box = renderObject is RenderBox ? renderObject : null;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: S.of(context).myModelingNote(note.title),
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).exportError(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note_alt_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? S.of(context).noNotes : S.of(context).noNotesFound,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? S.of(context).addFirstNote : S.of(context).tryChangingSearch,
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteNoteTitle),
        content: Text(S.of(context).deleteNoteConfirm(note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesCubit>().deleteNote(note.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
  }
}

class _NoteSharePoster extends StatelessWidget {
  final Note note;
  final GlobalKey boundaryKey;
  final String modelerName;

  const _NoteSharePoster({
    required this.note,
    required this.boundaryKey,
    required this.modelerName,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 800,
        color: Colors.white,
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Image.asset('assets/images/app_logo.png', width: 60, height: 60),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCALEBOOK - ${modelerName.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: AppColors.navyBlue,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const Text(
                      'Made in Poland with love for modellers',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.grey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 4, color: AppColors.red),
            const SizedBox(height: 32),
            Text(
              note.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.red,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 20,
                height: 1.4,
                color: Colors.black87,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
            if (note.link != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.link, size: 20, color: AppColors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.link!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.red,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            if (note.imageUrls.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: note.imageUrls
                    .map((url) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AppImage(
                            imageUrl: url,
                            width: 220,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Wygenerowano w aplikacji ScaleBook',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
