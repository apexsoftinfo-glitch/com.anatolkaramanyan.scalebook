import 'dart:ui' as ui;
import 'package:scalebook/l10n/app_localizations.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/widgets/cutting_mat_background.dart';
import '../../../core/design_system/widgets/app_image.dart';
import 'package:scalebook/features/session/domain/repositories/session_repository.dart';
import 'package:scalebook/features/home/domain/models/build_step.dart';
import 'package:scalebook/features/home/domain/models/model_project.dart';
import '../presentation/cubit/model_detail_cubit.dart';
import '../presentation/cubit/model_detail_state.dart';
import 'add_build_step_screen.dart';
import '../../../core/design_system/widgets/image_preview_screen.dart';

class ModelDetailScreen extends StatefulWidget {
  final String projectId;
  final String title;

  const ModelDetailScreen({
    super.key,
    required this.projectId,
    required this.title,
  });

  @override
  State<ModelDetailScreen> createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {
  late ModelDetailCubit _cubit;
  bool _isExporting = false;
  String _exportStatus = '';

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.I<ModelDetailCubit>()..loadProject(widget.projectId);
  }

  Future<void> _generateProgressImages(BuildContext context, dynamic project, List<dynamic> selectedSteps) async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Przygotowywanie... (1/4)';
    });

    try {
      if (!context.mounted) {
        return;
      }
      
      final sessionRepo = GetIt.I<SessionRepository>();
      final modelerName = sessionRepo.current.displayName;
      
      final documentsDir = await getApplicationDocumentsDirectory();
      final List<XFile> exportedFiles = [];

      const int stepsPerPage = 8;
      final int totalPages = (selectedSteps.length / stepsPerPage).ceil();

      for (int i = 0; i < totalPages; i++) {
        final int start = i * stepsPerPage;
        final int end = (start + stepsPerPage > selectedSteps.length) 
            ? selectedSteps.length 
            : start + stepsPerPage;
        final pageSteps = selectedSteps.sublist(start, end);
        
        setState(() => _exportStatus = 'Przygotowywanie strony ${i + 1} z $totalPages...');

        final boundaryKey = GlobalKey();
        final poster = _ProgressPoster(
          title: widget.title,
          steps: pageSteps,
          isA5: false,
          modelerName: modelerName,
          boundaryKey: boundaryKey,
          pageNumber: totalPages > 1 ? i + 1 : null,
          totalPages: totalPages > 1 ? totalPages : null,
        );

        if (!context.mounted) return;
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (overlayContext) => Positioned(
            left: -2000, 
            top: 0,
            child: Material(
              child: MediaQuery(
                data: MediaQuery.of(context),
                child: poster,
              ),
            ),
          ),
        );
        overlay.insert(overlayEntry);

        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (!context.mounted) return;
        final contextForBoundary = boundaryKey.currentContext;
        if (contextForBoundary != null) {
          final RenderRepaintBoundary? boundary = contextForBoundary.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final ui.Image image = await boundary.toImage(pixelRatio: 2.0); 
            final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final sanitizedTitle = widget.title.replaceAll(RegExp(r'[/\?%*:|"<>]'), '_');
              final String fileName = 'ScaleBook_${sanitizedTitle}_Page_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.png';
              final File file = File('${documentsDir.path}/$fileName');
              await file.writeAsBytes(byteData.buffer.asUint8List());
              exportedFiles.add(XFile(file.path));
            }
          } else {
          }
        } else {
        }
        overlayEntry.remove();
      }

      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });

      if (exportedFiles.isNotEmpty && context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await Share.shareXFiles(
          exportedFiles,
          text: S.of(context).myProgressTitle(widget.title),
          sharePositionOrigin: rect,
        );
      } else {
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorPrefix(e.toString())), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<void> _shareSingleStep(BuildContext context, BuildStep step) async {
    setState(() {
      _isExporting = true;
      _exportStatus = S.of(context).preparingStepPhoto;
    });

    try {
      if (!context.mounted) return;
      final boundaryKey = GlobalKey();
      final session = context.read<SessionCubit>().state;
      final modelerName = session.displayName;

      final poster = _SingleStepSharePoster(
        projectTitle: widget.title,
        step: step,
        modelerName: modelerName,
        boundaryKey: boundaryKey,
      );

      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -1200,
          child: Material(child: poster),
        ),
      );
      overlay.insert(overlayEntry);

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!context.mounted) return;

      final contextForBoundary = boundaryKey.currentContext;
      if (contextForBoundary == null || !contextForBoundary.mounted) {
        overlayEntry.remove();
        throw Exception('Nie odnaleziono kontekstu grafiki.');
      }

      final RenderRepaintBoundary? boundary = contextForBoundary.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        overlayEntry.remove();
        throw Exception('Nie zainicjowano obszaru renderowania.');
      }

      int retry = 0;
      while (!boundary.hasSize && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        retry++;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlayEntry.remove();
      
      if (byteData == null) throw Exception('Błąd konwersji obrazu');
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final documentsDir = await getApplicationDocumentsDirectory();
      final String fileName = 'ScaleBook_Step_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${documentsDir.path}/$fileName');
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
          text: S.of(context).buildStepProgressTitle(widget.title),
          sharePositionOrigin: rect,
        );
      }
    } catch (e) {
      debugPrint('Single Share Error: $e');
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorPrefix(e.toString())), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _showStepSelectionDialog(BuildContext context, ModelProject project) {
    if (project.steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brak etapów do udostępnienia.'))); // L10N
      return;
    }
    final sortedSteps = List<BuildStep>.from(project.steps)..sort((a, b) => b.date.compareTo(a.date));

    showDialog(
      context: context,
      builder: (dialogContext) {
        List<String> selectedIds = sortedSteps.map((s) => s.id).toList();
        return StatefulBuilder(
          builder: (builderContext, setState) {
            final bool allSelected = selectedIds.length == sortedSteps.length;
            return AlertDialog(
              title: Text(S.of(context).selectProgress),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      title: const Text('ZAZNACZ WSZYSTKO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.red)),
                      value: allSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedIds = sortedSteps.map((s) => s.id).toList();
                          } else {
                            selectedIds = [];
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                    const Divider(),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortedSteps.length,
                        itemBuilder: (context, index) {
                          final step = sortedSteps[index];
                          return CheckboxListTile(
                            title: Text(
                              '${step.date.day}.${step.date.month}.${step.date.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(step.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                            value: selectedIds.contains(step.id),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedIds.add(step.id);
                                } else {
                                  selectedIds.remove(step.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('ANULUJ')),
                ElevatedButton(
                  onPressed: selectedIds.isEmpty ? null : () async {
                    final selectedSteps = sortedSteps.where((s) => selectedIds.contains(s.id)).toList();
                    Navigator.pop(dialogContext);
                    await Future.delayed(const Duration(milliseconds: 200)); // Small delay to allow dialog to close
                    if (context.mounted) {
                      await _generateProgressImages(context, project, selectedSteps);
                    }
                  },
                  child: Text(S.of(context).share),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStatusMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (childContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.lightBlueAccent),
              title: Text(S.of(context).statusInProgress),
              onTap: () {
                _cubit.updateStatus('WARSZTAT');
                Navigator.pop(childContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause, color: Colors.orange),
              title: Text(S.of(context).statusPaused),
              onTap: () {
                _cubit.updateStatus('PAUSED');
                Navigator.pop(childContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(S.of(context).statusFinished),
              onTap: () {
                _cubit.updateStatus('FINISHED');
                Navigator.pop(childContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(widget.title.toUpperCase()),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _cubit.state.maybeMap(
                      loaded: (s) => _showStepSelectionDialog(context, s.project),
                      orElse: () {},
                    );
                  },
                ),
                BlocBuilder<ModelDetailCubit, ModelDetailState>(
                  builder: (context, state) {
                    final status = state.maybeMap(loaded: (s) => s.project.status, orElse: () => '');
                    Color iconColor = Colors.white;
                    if (status == 'WARSZTAT') {
                      iconColor = Colors.lightBlueAccent;
                    } else if (status == 'PAUSED') {
                      iconColor = Colors.orange;
                    } else if (status == 'FINISHED') {
                      iconColor = Colors.green;
                    }
                    return IconButton(
                      icon: Icon(Icons.info_outline, color: iconColor),
                      onPressed: () => _showStatusMenu(context),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                BlocBuilder<ModelDetailCubit, ModelDetailState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loaded: (s) => CuttingMatBackground(
                        child: _buildBuildLog(context, s.project),
                      ),
                      loading: (_) => const Center(child: CircularProgressIndicator()),
                      error: (s) => Center(child: Text(s.message)),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
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
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (childContext) => AddBuildStepScreen(
                      projectId: widget.projectId,
                      onSave: (step) => _cubit.addBuildStep(step),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add_a_photo),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuildLog(BuildContext context, ModelProject project) {
    final steps = project.steps;
    final sortedSteps = List<BuildStep>.from(steps)..sort((a, b) => b.date.compareTo(a.date));

    if (sortedSteps.isEmpty) {
      return Center(child: Text(S.of(context).noBuildSteps, style: const TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: sortedSteps.length,
      itemBuilder: (context, index) {
        final step = sortedSteps[index];
        final bool isLast = index == sortedSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line and dot
            SizedBox(
              width: 20,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  // Simple line without Expanded to avoid height issues
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 150, // Fixed height or similar to avoid IntrinsicHeight
                      color: Colors.white.withAlpha(40),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${step.date.day}.${step.date.month}.${step.date.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red, fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    step.note,
                                    style: const TextStyle(fontSize: 13, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                            if (step.imageUrl != null) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewScreen(imageUrl: step.imageUrl!))),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: AppImage(imageUrl: step.imageUrl, fit: BoxFit.cover, width: 100, height: 70),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Builder(
                              builder: (buttonContext) => IconButton(
                                icon: const Icon(Icons.ios_share, size: 16, color: AppColors.grey),
                                onPressed: () => _shareSingleStep(buttonContext, step),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.grey),
                              onPressed: () => _editStep(context, step),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.grey),
                              onPressed: () => _showDeleteStepConfirmation(context, step.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editStep(BuildContext context, BuildStep step) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (childContext) => AddBuildStepScreen(
          projectId: widget.projectId,
          initialStep: step,
          onSave: (updatedStep) => _cubit.updateBuildStep(updatedStep),
        ),
      ),
    );
  }

  void _showDeleteStepConfirmation(BuildContext context, String stepId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).deleteStep),
        content: Text(S.of(context).deleteStepConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(S.of(context).cancel)),
          TextButton(
            onPressed: () {
              _cubit.deleteBuildStep(stepId);
              Navigator.pop(dialogContext);
            },
            child: Text(S.of(context).delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProgressPoster extends StatelessWidget {
  final String title;
  final List<dynamic> steps;
  final bool isA5;
  final String modelerName;
  final GlobalKey boundaryKey;
  final int? pageNumber;
  final int? totalPages;

  const _ProgressPoster({
    required this.title,
    required this.steps,
    required this.isA5,
    required this.modelerName,
    required this.boundaryKey,
    this.pageNumber,
    this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final double width = 1000; 
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PosterGridPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                        Image.asset('assets/images/app_logo.png', width: 40, height: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCALEBOOK - ${(modelerName.isEmpty ? "GUEST" : modelerName).toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppColors.navyBlue,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const Text(
                              'Made in Poland with love for modellers',
                              style: TextStyle(
                                fontSize: 6,
                                color: AppColors.grey,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            (title.isEmpty ? "PROJECT" : title).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.navyBlue,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        if (pageNumber != null)
                          Text(
                            'SECTION $pageNumber / $totalPages',
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.none,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Interleaved Central Timeline
                    SizedBox(
                      height: (steps.length * 160.0) + 100, // Dynamic height based on steps
                      child: Stack(
                        children: [
                          // Central Vertical Line
                          Positioned(
                            top: 20,
                            bottom: 20,
                            left: 460, // Center: (1000 - 40*2) / 2 = 460
                            child: Container(
                              width: 2,
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          // Interleaved Steps
                          ...steps.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final step = entry.value;
                            final bool isRight = index % 2 != 0;
                            final double topOffset = index * 160.0;
                            
                            return Positioned(
                              top: topOffset,
                              left: 0,
                              right: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Side
                                  Expanded(
                                    child: !isRight 
                                      ? _buildTimelineCard(step, index, false, connector: Container(
                                          width: 40,
                                          height: 2,
                                          color: AppColors.navyBlue,
                                        ))
                                      : const SizedBox.shrink(),
                                  ),
                                  // Central Indicator
                                  Container(
                                    width: 40,
                                    margin: const EdgeInsets.only(left: 0, right: 0, top: 0),
                                    child: Center(
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.navyBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${(pageNumber != null ? (pageNumber! - 1) * 8 : 0) + index + 1}',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Right Side
                                  Expanded(
                                    child: isRight 
                                      ? _buildTimelineCard(step, index, true, connector: Container(
                                          width: 40,
                                          height: 2,
                                          color: AppColors.navyBlue,
                                        ))
                                      : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SCALEBOOK PROGRESS LOG',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppColors.navyBlue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const Text(
                          'MADE IN POLAND',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.none,
                          ),
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

  Widget _buildTimelineCard(dynamic step, int index, bool isRight, {Widget? connector}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) const Spacer(),
            if (isRight && connector != null) connector,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${step.date.day}.${step.date.month}.${step.date.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (!isRight && connector != null) connector,
            if (isRight) const Spacer(),
          ],
        ),
        const SizedBox(height: 4),
        if (step.imageUrl != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(
                imageUrl: step.imageUrl, 
                fit: BoxFit.cover, 
                width: 440,
                height: 240,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          step.note,
          textAlign: isRight ? TextAlign.left : TextAlign.right,
          style: const TextStyle(
            color: AppColors.navyBlue, 
            fontSize: 11, 
            decoration: TextDecoration.none,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SingleStepSharePoster extends StatelessWidget {
  final String projectTitle;
  final BuildStep step;
  final String modelerName;
  final GlobalKey boundaryKey;

  const _SingleStepSharePoster({
    required this.projectTitle,
    required this.step,
    required this.modelerName,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 600,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PosterGridPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/app_logo.png', width: 40, height: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCALEBOOK - ${modelerName.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.navyBlue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const Text(
                            'Made in Poland with love for modellers',
                            style: TextStyle(
                              fontSize: 6,
                              color: AppColors.grey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    projectTitle.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (step.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AppImage(
                        imageUrl: step.imageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    '${step.date.day}.${step.date.month}.${step.date.year}',
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.note,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Wygenerowano w aplikacji ScaleBook',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.grey,
                        fontStyle: FontStyle.italic,
                        decoration: TextDecoration.none,
                      ),
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
}

class _PosterGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navyBlue.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    const double step = 40.0;

    // Draw grid
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Technical markings
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (double i = 0; i < size.width; i += 200) {
      textPainter.text = TextSpan(
        text: '${i.toInt()}',
        style: TextStyle(color: AppColors.navyBlue.withValues(alpha: 0.3), fontSize: 8, decoration: TextDecoration.none),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i + 2, 2));
    }

    // Border
    final borderPaint = Paint()
      ..color = AppColors.navyBlue.withValues(alpha: 0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
