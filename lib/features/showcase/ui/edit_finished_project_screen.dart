import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';
import '../../../../core/design_system/widgets/showcase_stage_background.dart';
import '../../../../core/services/image_service.dart';
import '../../home/domain/models/model_project.dart';
import '../../home/presentation/cubit/home_cubit.dart';

class EditFinishedProjectScreen extends StatefulWidget {
  final ModelProject project;

  const EditFinishedProjectScreen({
    super.key,
    required this.project,
  });

  @override
  State<EditFinishedProjectScreen> createState() => _EditFinishedProjectScreenState();
}

class _EditFinishedProjectScreenState extends State<EditFinishedProjectScreen> {
  late TextEditingController _notesController;
  final _imagePicker = ImagePicker();
  
  File? _newMainImage;
  String? _existingMainImageUrl;
  
  final List<File> _newGalleryImages = [];
  final List<String> _existingGalleryUrls = [];
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.project.finalNotes);
    _existingMainImageUrl = widget.project.finishedMainImageUrl;
    _existingGalleryUrls.addAll(widget.project.finishedGalleryUrls);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _newMainImage = File(image.path);
        _existingMainImageUrl = null;
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final int remainingSlots = 15 - (_newGalleryImages.length + _existingGalleryUrls.length);
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksymalnie 15 dodatkowych zdjęć.')),
      );
      return;
    }

    final List<XFile> images = await _imagePicker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _newGalleryImages.addAll(images.take(remainingSlots).map((x) => File(x.path)));
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    try {
      final imageService = GetIt.I<ImageService>();
      
      // 1. Upload main image if new
      String? mainUrl = _existingMainImageUrl;
      if (_newMainImage != null) {
        mainUrl = await imageService.saveImage(_newMainImage!);
      }
      
      // 2. Upload new gallery images
      final List<String> finalGalleryUrls = List.from(_existingGalleryUrls);
      for (var file in _newGalleryImages) {
        final url = await imageService.saveImage(file);
        finalGalleryUrls.add(url);
      }
      
      // 3. Update project
      final updatedProject = widget.project.copyWith(
        finishedMainImageUrl: mainUrl,
        finishedGalleryUrls: finalGalleryUrls,
        finalNotes: _notesController.text,
        finishedAt: DateTime.now(),
      );
      
      if (mounted) {
        await context.read<HomeCubit>().updateProject(updatedProject);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd podczas zapisywania: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('EDYCJA GABLITY', style: TextStyle(letterSpacing: 2, fontSize: 16)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('ZAPISZ', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: ShowcaseStageBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ZDJĘCIE GŁÓWNE', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickMainImage,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: _buildMainImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DODATKOWE UJĘCIA (MAX 15)', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
                  Text('${_newGalleryImages.length + _existingGalleryUrls.length}/15', style: const TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 12),
              _buildGalleryGrid(),
              const SizedBox(height: 32),
              const Text('UWAGI KOŃCOWE / PODSUMOWANIE', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 8,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Jak oceniasz ten model? Jakie techniki zastosowałeś? Czy wystąpiły problemy?',
                  hintStyle: const TextStyle(color: Colors.white12, fontSize: 14),
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainImagePreview() {
    if (_newMainImage != null) {
      return Image.file(_newMainImage!, fit: BoxFit.cover);
    }
    if (_existingMainImageUrl != null) {
      return AppImage(imageUrl: _existingMainImageUrl!, fit: BoxFit.cover);
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.white24, size: 40),
        SizedBox(height: 8),
        Text('WYBIERZ ZDJĘCIE GŁÓWNE', style: TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _buildGalleryGrid() {
    final totalCount = _existingGalleryUrls.length + _newGalleryImages.length;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalCount + 1,
      itemBuilder: (context, index) {
        if (index == totalCount) {
          return GestureDetector(
            onTap: _pickGalleryImages,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.add_photo_alternate, color: Colors.white24),
            ),
          );
        }

        // Show existing images first, then new ones
        if (index < _existingGalleryUrls.length) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AppImage(imageUrl: _existingGalleryUrls[index], fit: BoxFit.cover),
              Positioned(
                top: 0, right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _existingGalleryUrls.removeAt(index)),
                ),
              ),
            ],
          );
        } else {
          final newIndex = index - _existingGalleryUrls.length;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(_newGalleryImages[newIndex], fit: BoxFit.cover),
              Positioned(
                top: 0, right: 0,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _newGalleryImages.removeAt(newIndex)),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
