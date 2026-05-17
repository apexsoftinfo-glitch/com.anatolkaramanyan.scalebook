import 'dart:io';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/services/image_service.dart';
import '../domain/models/model_project.dart';
import '../presentation/cubit/home_cubit.dart';
import 'widgets/coffee_donation_modal.dart';

class AddModelScreen extends StatefulWidget {
  final bool initialIsStash;
  const AddModelScreen({super.key, this.initialIsStash = false});

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
  bool _isStash = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isStash = widget.initialIsStash;
  }

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

  Future<void> _openScaleMates() async {
    final url = Uri.parse('https://www.scalemates.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).newModel), // L10N
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
          ),
          SingleChildScrollView(
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
                        color: Colors.white,
                        border: Border.all(
                          color: _selectedImage == null ? AppColors.grey : AppColors.navyBlue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                Text(
                                  S.of(context).boxPhotoRequired, // L10N
                                  style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          S.of(context).scaleMatesLinkText,
                          style: const TextStyle(color: AppColors.grey, fontSize: 11),
                        ),
                        GestureDetector(
                          onTap: _openScaleMates,
                          child: const Text(
                            'ScaleMates',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        S.of(context).addToStash,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBlue,
                        ),
                      ),
                      subtitle: Text(S.of(context).stashSectionDescription),
                      value: _isStash,
                      activeThumbColor: AppColors.red,
                      onChanged: (val) => setState(() => _isStash = val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: S.of(context).modelNameLabel, // L10N
                    controller: _titleController,
                    hint: 'np. Nissan Skyline R34',
                    validator: (v) => v?.isEmpty ?? true ? S.of(context).modelNameRequired : null, // L10N
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: S.of(context).scaleLabel, // L10N
                    controller: _scaleController,
                    hint: 'np. 1/24',
                    validator: (v) => v?.isEmpty ?? true ? S.of(context).scaleRequired : null, // L10N
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isStash ? S.of(context).purchaseDate : S.of(context).startDate, // L10N
                    style: const TextStyle(
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
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_isStash ? S.of(context).addToStash : S.of(context).addToWorkshop),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        SnackBar(content: Text(S.of(context).addPhotoError)), // L10N
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
          status: _isStash ? 'GARDEROBA' : 'WARSZTAT', // L10N
          progress: 0.0,
          mainImageUrl: savedImagePath,
          createdAt: _startDate,
        );

        if (!context.mounted) return;
        await context.read<HomeCubit>().addProject(newProject);
        
        final prefs = await SharedPreferences.getInstance();
        int addedCount = (prefs.getInt('added_projects_count') ?? 0) + 1;
        await prefs.setInt('added_projects_count', addedCount);

        if (!context.mounted) return;
        if (addedCount > 0 && addedCount % 5 == 0) {
          await showDialog(
            context: context,
            builder: (context) => const CoffeeDonationModal(),
          );
        }

        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).savingError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navyBlue.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const double step = 20.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
