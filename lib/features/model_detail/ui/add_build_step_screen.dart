import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import '../../home/domain/models/build_step.dart';
import 'package:scalebook/core/design_system/app_colors.dart';
import 'package:scalebook/core/design_system/widgets/cutting_mat_background.dart';
import 'package:scalebook/core/design_system/widgets/app_image.dart';
import 'package:scalebook/core/services/image_service.dart';
import 'package:uuid/uuid.dart';

class AddBuildStepScreen extends StatefulWidget {
  final String projectId;
  final BuildStep? initialStep;
  final Function(BuildStep) onSave;

  const AddBuildStepScreen({
    super.key, 
    required this.projectId,
    this.initialStep,
    required this.onSave,
  });

  @override
  State<AddBuildStepScreen> createState() => _AddBuildStepScreenState();
}

class _AddBuildStepScreenState extends State<AddBuildStepScreen> {
  late TextEditingController _noteController;
  int _durationMinutes = 30;
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  late DateTime _selectedDate;
  bool _isSaving = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialStep?.note ?? '');
    _selectedDate = widget.initialStep?.date ?? DateTime.now();
    _existingImageUrl = widget.initialStep?.imageUrl;
    _durationMinutes = widget.initialStep?.durationMinutes ?? 30;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatDurationValue(BuildContext context, int minutes) {
    final isPl = Localizations.localeOf(context).languageCode == 'pl';
    final minSuffix = 'min'; // L10N
    final hourSuffix = isPl ? 'godz.' : 'h'; // L10N
    
    if (minutes < 60) {
      return '$minutes $minSuffix';
    }
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) {
      return '$h $hourSuffix';
    }
    return '$h $hourSuffix $m $minSuffix';
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _existingImageUrl = null; // New image selected
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
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).addStepDescription)), // L10N
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? savedImagePath = _existingImageUrl;
      if (_selectedImage != null) {
        savedImagePath = await GetIt.I<ImageService>().saveImage(_selectedImage!);
      }

      final step = BuildStep(
        id: widget.initialStep?.id ?? const Uuid().v4(),
        projectId: widget.projectId,
        date: _selectedDate,
        note: _noteController.text,
        imageUrl: savedImagePath,
        durationMinutes: _durationMinutes,
      );

      widget.onSave(step);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorSaving(e.toString()))), // L10N
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStep != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? S.of(context).editStepLabel : S.of(context).newBuildStep), // L10N
      ),
      body: CuttingMatBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                    ),
                    child: _buildImageWidget(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppColors.navyBlue),
                  title: Text(
                    S.of(context).stepDate, // L10N
                    style: TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16, color: AppColors.navyBlue, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: AppColors.navyBlue),
                              const SizedBox(width: 8),
                              Text(
                                S.of(context).stepDurationLabel.replaceAll(' (WYMAGANE)', '').replaceAll(' (REQUIRED)', ''), // L10N
                                style: TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            _formatDurationValue(context, _durationMinutes),
                            style: const TextStyle(fontSize: 16, color: AppColors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _durationMinutes.toDouble(),
                        min: 1,
                        max: _durationMinutes > 300 ? _durationMinutes.toDouble() : 300,
                        activeColor: AppColors.red,
                        inactiveColor: AppColors.lightGrey,
                        onChanged: (val) {
                          setState(() {
                            _durationMinutes = val.round();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [15, 30, 45, 60, 90, 120, 180, 240, 300].map((mins) {
                            final label = _formatDurationValue(context, mins);
                            final isSelected = _durationMinutes == mins;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _durationMinutes = mins;
                                    });
                                  }
                                },
                                selectedColor: AppColors.red,
                                backgroundColor: AppColors.lightGrey,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.navyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).stepDescriptionLabel, // L10N
                        style: TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 16, color: AppColors.navyBlue, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: S.of(context).stepDescriptionHint, // L10N
                          hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
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
                    : Text(isEditing ? S.of(context).saveChanges : S.of(context).saveStep), // L10N
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    if (_existingImageUrl != null) {
      if (_existingImageUrl!.startsWith('http')) {
        return Image.network(_existingImageUrl!, fit: BoxFit.cover);
      } else {
        return AppImage(imageUrl: _existingImageUrl!, fit: BoxFit.cover);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_a_photo, size: 64, color: AppColors.navyBlue),
        const SizedBox(height: 8),
        Text(
          S.of(context).addPhoto, // L10N
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
      ],
    );
  }
}
