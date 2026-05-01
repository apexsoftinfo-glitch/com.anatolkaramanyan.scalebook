import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/widgets/cutting_mat_background.dart';
import '../presentation/cubit/model_detail_cubit.dart';
import '../presentation/cubit/model_detail_state.dart';
import 'add_build_step_screen.dart';
import '../../../core/design_system/widgets/image_preview_screen.dart';

class ModelDetailScreen extends StatelessWidget {
  final String projectId;
  final String title;

  const ModelDetailScreen({
    super.key,
    required this.projectId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ModelDetailCubit>()..loadProject(projectId),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title.toUpperCase()),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'HISTORIA BUDOWY'), // L10N
                Tab(text: 'GALERIA'), // L10N
              ],
              indicatorColor: AppColors.red,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.grey,
            ),
          ),
          body: BlocBuilder<ModelDetailCubit, ModelDetailState>(
            builder: (context, state) {
              return state.maybeMap(
                loaded: (s) => CuttingMatBackground(
                  child: TabBarView(
                    children: [
                      _buildBuildLog(context, s.project),
                      _buildGallery(context, s.project),
                    ],
                  ),
                ),
                error: (s) => Center(child: Text(s.message)),
                orElse: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
          floatingActionButton: BlocBuilder<ModelDetailCubit, ModelDetailState>(
            builder: (context, state) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (childContext) => AddBuildStepScreen(
                        projectId: projectId,
                        onSave: (step) {
                          context.read<ModelDetailCubit>().addBuildStep(step);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text('DODAJ ETAP'), // L10N
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBuildLog(BuildContext context, dynamic project) {
    final steps = project.steps;
    if (steps.isEmpty) {
      return const Center(child: Text('Brak wpisów. Dodaj swój pierwszy krok!')); // L10N
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return _buildLogEntry(context, steps[index], index == steps.length - 1);
      },
    );
  }

  Widget _buildLogEntry(BuildContext context, dynamic step, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.circle, size: 12, color: AppColors.red),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.red.withAlpha(76),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Dismissible(
                key: Key(step.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await _showDeleteStepConfirmation(context);
                },
                onDismissed: (direction) {
                  context.read<ModelDetailCubit>().deleteBuildStep(step.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (childContext) => AddBuildStepScreen(
                            projectId: projectId,
                            initialStep: step,
                            onSave: (updatedStep) {
                              context.read<ModelDetailCubit>().updateBuildStep(updatedStep);
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${step.date.day}/${step.date.month}/${step.date.year}', // L10N
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step.note,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          if (step.imageUrl != null) ...[
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImagePreviewScreen(
                                      imageUrl: step.imageUrl!,
                                      title: 'ZDJĘCIE ETAPU', // L10N
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: step.imageUrl!,
                                child: Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: step.imageUrl!.startsWith('http')
                                          ? NetworkImage(step.imageUrl!)
                                          : FileImage(File(step.imageUrl!)) as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteStepConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('USUNĄĆ ETAP?'), // L10N
        content: const Text('Czy na pewno chcesz usunąć ten wpis z historii? Tej operacji nie można cofnąć.'), // L10N
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANULUJ'), // L10N
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('USUŃ'), // L10N
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else {
      return Image.file(File(path), fit: BoxFit.cover);
    }
  }

  Widget _buildGallery(BuildContext context, dynamic project) {
    final urls = project.galleryUrls;
    if (urls.isEmpty) {
      return const Center(child: Text('Brak zdjęć w galerii.')); // L10N
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewScreen(
                  imageUrl: urls[index],
                  title: 'GALERIA', // L10N
                ),
              ),
            );
          },
          child: Hero(
            tag: urls[index],
            child: _buildImage(urls[index]),
          ),
        );
      },
    );
  }
}
