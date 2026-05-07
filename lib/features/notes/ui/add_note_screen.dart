import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:scalebook/core/design_system/app_colors.dart';
import 'package:scalebook/core/design_system/widgets/app_image.dart';
import 'package:scalebook/core/services/image_service.dart';
import '../domain/models/note_model.dart';
import '../presentation/cubit/notes_cubit.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _linkController;
  final _imagePicker = ImagePicker();
  final List<File> _selectedNewImages = [];
  late List<String> _existingImageUrls;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    _linkController = TextEditingController(text: widget.note?.link);
    _existingImageUrls = List.from(widget.note?.imageUrls ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedNewImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } else {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedNewImages.add(File(image.path));
        });
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(S.of(context).gallery), // L10N
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(S.of(context).camera), // L10N
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedNewImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? S.of(context).editNote : S.of(context).newNote), // L10N
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                label: S.of(context).noteNameLabel, // L10N
                controller: _titleController,
                hint: S.of(context).noteNameHint,
                validator: (v) => v?.isEmpty ?? true ? S.of(context).nameRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: S.of(context).noteContentLabel, // L10N
                controller: _contentController,
                hint: S.of(context).noteContentHint,
                maxLines: 5,
                validator: (v) => v?.isEmpty ?? true ? S.of(context).contentRequired : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: S.of(context).noteLinkLabel, // L10N
                controller: _linkController,
                hint: S.of(context).noteLinkHint,
              ),
              const SizedBox(height: 24),
              Text(
                S.of(context).notePhotosLabel, // L10N
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildImageGrid(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? S.of(context).saveChanges : S.of(context).saveNote), // L10N
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final totalImages = _existingImageUrls.length + _selectedNewImages.length;
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: totalImages + 1,
          itemBuilder: (context, index) {
            if (index == totalImages) {
              return GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.grey.withAlpha(100), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo, color: AppColors.grey),
                ),
              );
            }

            final isExisting = index < _existingImageUrls.length;
            final imageContent = isExisting
                ? AppImage(imageUrl: _existingImageUrls[index], fit: BoxFit.cover)
                : Image.file(_selectedNewImages[index - _existingImageUrls.length], fit: BoxFit.cover);

            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageContent,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => isExisting 
                        ? _removeExistingImage(index) 
                        : _removeNewImage(index - _existingImageUrls.length),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final List<String> imageUrls = [..._existingImageUrls];
        for (final file in _selectedNewImages) {
          final path = await GetIt.I<ImageService>().saveImage(file);
          imageUrls.add(path);
        }

        final isEditing = widget.note != null;
        final note = isEditing 
            ? widget.note!.copyWith(
                title: _titleController.text,
                content: _contentController.text,
                imageUrls: imageUrls,
                link: _linkController.text.isNotEmpty ? _linkController.text : null,
                updatedAt: DateTime.now(),
              )
            : Note(
                id: const Uuid().v4(),
                userId: '', // Set by repository
                title: _titleController.text,
                content: _contentController.text,
                imageUrls: imageUrls,
                link: _linkController.text.isNotEmpty ? _linkController.text : null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

        if (!mounted) return;
        if (isEditing) {
          await context.read<NotesCubit>().updateNote(note);
        } else {
          await context.read<NotesCubit>().addNote(note);
        }
        
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorSaving(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
