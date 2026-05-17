import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import '../../../../core/design_system/widgets/showcase_stage_background.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../home/presentation/cubit/home_cubit.dart';
import '../../home/presentation/cubit/home_state.dart';
import 'widgets/showcase_model_list_tile.dart';
import 'widgets/showcase_model_card.dart';
import 'finished_gallery_screen.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E12),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          S.of(context).showcaseTitle,
          style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.w200),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Widok listy' : 'Widok siatki',
          ),
        ],
      ),
      body: ShowcaseStageBackground(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.maybeMap(
              loaded: (s) {
                var finishedProjects = s.projects.where((p) => p.status == 'FINISHED').toList();

                if (_searchQuery.isNotEmpty) {
                  finishedProjects = finishedProjects
                      .where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Sort by newest finished
                finishedProjects.sort((a, b) {
                  final aDate = a.finishedAt ?? a.createdAt;
                  final bDate = b.finishedAt ?? b.createdAt;
                  return bDate.compareTo(aDate);
                });

                return _buildContent(context, finishedProjects);
              },
              error: (s) => Center(child: Text(s.message)),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> projects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Search Field
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'SZUKAJ W GABLOCIE...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (projects.isEmpty && _searchQuery.isEmpty)
            _buildEmptyState()
          else if (projects.isEmpty && _searchQuery.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  S.of(context).noModelsFound,
                  style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else ...[
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Text(
                  '${projects.length} UKOŃCZONE PROJEKTY',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isGridView ? _buildGrid(projects) : _buildList(projects),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(List<dynamic> projects) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 20,
        mainAxisSpacing: 32,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final model = projects[index];
        return _buildAnimatedItem(
          index: index,
          onTap: () => _navigateToDetail(model),
          child: ShowcaseModelCard(
            title: model.title,
            scale: model.scale,
            imageUrl: model.finishedMainImageUrl ?? model.mainImageUrl,
          ),
        );
      },
    );
  }

  Widget _buildList(List<dynamic> projects) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final model = projects[index];
        return _buildAnimatedItem(
          index: index,
          onTap: () => _navigateToDetail(model),
          child: ShowcaseModelListTile(
            title: model.title,
            scale: model.scale,
            imageUrl: model.finishedMainImageUrl ?? model.mainImageUrl,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedItem({
    required int index,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 800)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }

  void _navigateToDetail(dynamic model) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinishedGalleryScreen(
          projectId: model.id,
        ),
      ),
    );
    if (!mounted) return;
    context.read<HomeCubit>().loadProjects();
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 80, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 24),
              const Text(
                'TWOJA GABLOTA JEST PUSTA',
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w200, letterSpacing: 3),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dokończ model na warsztacie, aby tu trafił!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
