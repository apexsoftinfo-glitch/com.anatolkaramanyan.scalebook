import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/widgets/app_image.dart';
import '../../../../core/design_system/widgets/showcase_stage_background.dart';
import '../../home/domain/models/model_project.dart';
import '../../home/presentation/cubit/home_cubit.dart';
import '../../home/presentation/cubit/home_state.dart';
import '../../session/domain/repositories/session_repository.dart';
import 'edit_finished_project_screen.dart';
import '../../model_detail/ui/model_detail_screen.dart';
import '../../../../core/design_system/widgets/image_preview_screen.dart';
import 'package:share_plus/share_plus.dart';

class FinishedGalleryScreen extends StatefulWidget {
  final String projectId;

  const FinishedGalleryScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<FinishedGalleryScreen> createState() => _FinishedGalleryScreenState();
}

class _FinishedGalleryScreenState extends State<FinishedGalleryScreen> {
  bool _isExporting = false;
  String _exportStatus = '';


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return state.maybeMap(
          loaded: (s) {
            final project = s.projects.firstWhere((p) => p.id == widget.projectId);
            final hasPhotos = project.finishedMainImageUrl != null || project.finishedGalleryUrls.isNotEmpty;

            return Scaffold(
              backgroundColor: const Color(0xFF0A0E12),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  project.title.toUpperCase(),
                  style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w300, fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                    onPressed: () => _openEdit(context, project),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  ShowcaseStageBackground(
                    child: hasPhotos ? _buildGallery(context, project) : _buildEmpty(context, project),
                  ),
                  if (_isExporting)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppColors.red),
                            const SizedBox(height: 24),
                            Text(
                              _exportStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          orElse: () => const Scaffold(
            backgroundColor: Color(0xFF0A0E12),
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, ModelProject project) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 80, color: Colors.white10),
            const SizedBox(height: 24),
            const Text(
              'BRAK ZDJĘĆ UKOŃCZONEGO MODELU',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w200, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pochwal się swoim dziełem! Wybierz główne zdjęcie i dodaj ujęcia detali.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openEdit(context, project),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('DODAJ ZDJĘCIA KOŃCOWE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(BuildContext context, ModelProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Photo (Hero style)
          if (project.finishedMainImageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(
                        imageUrl: project.finishedMainImageUrl!,
                        title: project.title,
                      ),
                    ),
                  ),
                  child: AppImage(
                    imageUrl: project.finishedMainImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Additional Photos Grid
          if (project.finishedGalleryUrls.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'DETALE PROJEKTU',
                style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: project.finishedGalleryUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12),
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImagePreviewScreen(
                          imageUrl: project.finishedGalleryUrls[index],
                          title: project.title,
                        ),
                      ),
                    ),
                    child: AppImage(
                      imageUrl: project.finishedGalleryUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],

          // Final Notes
          if (project.finalNotes != null && project.finalNotes!.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'UWAGI KOŃCOWE',
                style: TextStyle(color: AppColors.red, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                project.finalNotes!,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontWeight: FontWeight.w300),
              ),
            ),
          ],

          // Statistics Section
          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'STATYSTYKI PROJEKTU',
              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsRow(context, project),
          
          const SizedBox(height: 60),
          _buildActionButtons(context, project),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ModelProject project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModelDetailScreen(
                      projectId: project.id,
                      title: project.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.history_outlined),
              label: const Text('ZOBACZ ETAPY BUDOWY'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _presentModel(context, project),
              icon: const Icon(Icons.stars),
              label: const Text('ZAPREZENTUJ MODEL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 10,
                shadowColor: AppColors.red.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ModelProject project) {
    int duration = 0;
    if (project.steps.isNotEmpty) {
      final stepDates = project.steps.map((s) => s.date).toList();
      final firstDate = stepDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final lastDate = stepDates.reduce((a, b) => a.isAfter(b) ? a : b);
      // Duration in days from first to last step (inclusive)
      duration = lastDate.difference(DateTime(firstDate.year, firstDate.month, firstDate.day)).inDays + 1;
    }
    final stepsCount = project.steps.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'CZAS BUDOWY',
            value: '$duration DNI',
            icon: Icons.timer_outlined,
          ),
          Container(width: 1, height: 40, color: Colors.white12),
          _buildStatItem(
            label: 'ETAPY PRAC',
            value: '$stepsCount',
            icon: Icons.history_edu_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.red, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }

  void _openEdit(BuildContext context, ModelProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFinishedProjectScreen(project: project),
      ),
    );
  }

  Future<void> _presentModel(BuildContext context, ModelProject project) async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Przygotowywanie prezentacji...';
    });

    try {
      final boundaryKey = GlobalKey();
      
      // Get modeler name
      final sessionRepo = GetIt.I<SessionRepository>();
      final modelerName = sessionRepo.current.displayName;

      final poster = _ShowcasePoster(
        project: project,
        modelerName: modelerName,
        boundaryKey: boundaryKey,
      );

      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -2000,
          child: Material(child: poster),
        ),
      );
      overlay.insert(overlayEntry);

      // Wait for layout and image loading
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (!context.mounted) return;
      final contextForBoundary = boundaryKey.currentContext;
      if (contextForBoundary == null) {
        overlayEntry.remove();
        throw Exception('Błąd renderowania grafiki.');
      }

      final RenderRepaintBoundary? boundary = contextForBoundary.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        overlayEntry.remove();
        throw Exception('Błąd obszaru renderowania.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlayEntry.remove();

      if (byteData == null) throw Exception('Błąd konwersji obrazu.');
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final String fileName = 'ScaleBook_Showcase_${project.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Mój ukończony projekt: ${project.title} #ScaleBook',
          sharePositionOrigin: rect,
        );
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd eksportu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// --- POSTER WIDGET FOR EXPORT ---

class _ShowcasePoster extends StatelessWidget {
  final ModelProject project;
  final String modelerName;
  final GlobalKey boundaryKey;

  const _ShowcasePoster({
    required this.project,
    required this.modelerName,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 1200;
    int duration = 0;
    if (project.steps.isNotEmpty) {
      final stepDates = project.steps.map((s) => s.date).toList();
      final firstDate = stepDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final lastDate = stepDates.reduce((a, b) => a.isAfter(b) ? a : b);
      duration = lastDate.difference(DateTime(firstDate.year, firstDate.month, firstDate.day)).inDays + 1;
    }
    final stepsCount = project.steps.length;

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
        ),
        child: Stack(
          children: [
            // Technical background (Light Theme)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [Colors.white, Color(0xFFE2E8F0)],
                  ),
                ),
              ),
            ),
            // Subtle technical grid
            Positioned.fill(
              child: CustomPaint(
                painter: _PosterGridPainter(color: Colors.black.withValues(alpha: 0.03)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                project.title.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SKALA ${project.scale} | MODELER: ${modelerName.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // App Identity
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'SCALEBOOK',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const Text(
                            'DIGITAL WORKBENCH',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Main Photo Section
                  if (project.finishedMainImageUrl != null)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: AppImage(
                          imageUrl: project.finishedMainImageUrl,
                          width: 1080,
                          height: 600,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Detail Gallery Row
                  if (project.finishedGalleryUrls.isNotEmpty)
                    Center(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: project.finishedGalleryUrls.map((url) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                            ),
                            child: AppImage(
                              imageUrl: url,
                              width: 288,
                              height: 207,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const SizedBox(height: 60),
                  
                  // Stats and Notes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.03),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            _buildPosterStat('CZAS BUDOWY', '$duration DNI'),
                            Container(width: 1, height: 60, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 40)),
                            _buildPosterStat('ETAPY PRAC', '$stepsCount'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 40),
                      
                      // Notes
                      if (project.finalNotes != null && project.finalNotes!.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UWAGI KOŃCOWE',
                                style: TextStyle(color: AppColors.red, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                project.finalNotes!,
                                style: const TextStyle(color: AppColors.navyBlue, fontSize: 18, height: 1.5, fontWeight: FontWeight.w400),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Footer Technical Line
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'GENERATED BY SCALEBOOK - THE PROFESSIONAL MODELLING LOG APP',
                      style: TextStyle(color: Colors.black26, fontSize: 10, letterSpacing: 4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black38, fontSize: 10, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: AppColors.navyBlue, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _PosterGridPainter extends CustomPainter {
  final Color color;
  _PosterGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
