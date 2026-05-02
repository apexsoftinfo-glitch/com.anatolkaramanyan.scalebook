import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/widgets/cutting_mat_background.dart';
import '../../../core/services/image_service.dart';
import '../domain/models/model_project.dart';
import '../presentation/cubit/home_cubit.dart';

class AddModelScreen extends StatefulWidget {
  const AddModelScreen({super.key});

  @override
  State<AddModelScreen> createState() => _AddModelScreenState();
}

class _AddModelScreenState extends State<AddModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _scaleController = TextEditingController(text: '1/24');
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
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
              title: const Text('Galeria'), // L10N
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Aparat'), // L10N
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.red,
              onPrimary: Colors.white,
              onSurface: AppColors.navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOWY PROJEKT'), // L10N
      ),
      body: CuttingMatBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      border: Border.all(
                        color: _selectedImage == null ? AppColors.grey : AppColors.navyBlue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 48, color: AppColors.grey),
                              const SizedBox(height: 8),
                              const Text(
                                'ZDJĘCIE OPAKOWANIA (WYMAGANE)', // L10N
                                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'NAZWA MODELU', // L10N
                  controller: _titleController,
                  hint: 'np. Nissan Skyline R34',
                  validator: (v) => v?.isEmpty ?? true ? 'Nazwa jest obowiązkowa' : null, // L10N
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'SKALA', // L10N
                  controller: _scaleController,
                  hint: 'np. 1/24',
                  validator: (v) => v?.isEmpty ?? true ? 'Skala jest obowiązkowa' : null, // L10N
                ),
                const SizedBox(height: 16),
                const Text(
                  'DATA ROZPOCZĘCIA', // L10N
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.grey.withAlpha(100)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: const TextStyle(fontSize: 16, color: AppColors.navyBlue),
                        ),
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.navyBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('DODAJ DO WARSZTATU'), // L10N
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
              letterSpacing: 1.2,
            )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
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

  Future<void> _submit(BuildContext context) async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj zdjęcie opakowania przed zapisaniem.')), // L10N
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final savedImagePath = await GetIt.I<ImageService>().saveImage(_selectedImage!);
        
        final newProject = ModelProject(
          id: const Uuid().v4(),
          title: _titleController.text,
          scale: _scaleController.text,
          status: 'W trakcie', // L10N
          progress: 0.0,
          mainImageUrl: savedImagePath,
          createdAt: _startDate,
        );

        if (!context.mounted) return;
        
        // Use await here to catch errors from the repository
        await context.read<HomeCubit>().addProject(newProject);
        
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd podczas zapisywania w chmurze: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}
