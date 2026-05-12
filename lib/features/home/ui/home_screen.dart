import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/design_system/widgets/cutting_mat_background.dart';
import '../../../../core/design_system/app_colors.dart';
import '../presentation/cubit/home_cubit.dart';
import '../presentation/cubit/home_state.dart';
import 'widgets/model_card.dart';
import 'add_model_screen.dart';
import '../../settings/ui/settings_screen.dart';
import '../../model_detail/ui/model_detail_screen.dart';
import '../../session/domain/models/user_session.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../../../../core/design_system/widgets/limit_dialog.dart';
import '../../welcome/ui/auth_screen.dart';
import '../../../../core/design_system/widgets/app_image.dart';
import '../domain/models/model_project.dart';

enum HomeSortMode { date, status }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSortMode _sortMode = HomeSortMode.date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).appTitle), // L10N
              const Text(
                'Made in Poland with love for modellers',
                style: TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today, 
                color: _sortMode == HomeSortMode.date ? AppColors.red : Colors.white),
              tooltip: S.of(context).sortByDate,
              onPressed: () => setState(() => _sortMode = HomeSortMode.date),
            ),
            IconButton(
              icon: Icon(Icons.playlist_add_check, 
                color: _sortMode == HomeSortMode.status ? AppColors.red : Colors.white),
              tooltip: S.of(context).sortByStatus,
              onPressed: () => setState(() => _sortMode = HomeSortMode.status),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: CuttingMatBackground(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return state.maybeMap(
                loaded: (s) {
                  final activeProjects = s.projects.where((p) => p.status != 'GARDEROBA' && p.status != 'FINISHED').toList();
                  
                  // Apply Sorting
                  activeProjects.sort((a, b) {
                    if (_sortMode == HomeSortMode.date) {
                      return b.createdAt.compareTo(a.createdAt);
                    } else {
                      // Status: WARSZTAT first, then others (PAUSED)
                      if (a.status == b.status) {
                        return b.createdAt.compareTo(a.createdAt);
                      }
                      if (a.status == 'WARSZTAT') return -1;
                      if (b.status == 'WARSZTAT') return 1;
                      return 0;
                    }
                  });

                  return _buildGrid(context, activeProjects);
                },
                error: (s) => Center(child: Text(s.message)),
                orElse: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        floatingActionButton: BlocBuilder<SessionCubit, UserSession>(
          builder: (context, session) {
            return FloatingActionButton(
              heroTag: 'home_fab',
              onPressed: () => _showAddSelectionDialog(context, session),
              child: const Icon(Icons.add),
            );
          },
        ),
      );
  }

  void _showAddSelectionDialog(BuildContext context, UserSession session) {
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                S.of(context).addProjectDialogTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.navyBlue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.red),
              title: Text(S.of(context).addNewProjectOption),
              onTap: () {
                Navigator.pop(modalContext);
                _navigateToAddModel(context, session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shelves, color: AppColors.navyBlue),
              title: Text(S.of(context).chooseFromStashOption),
              onTap: () {
                Navigator.pop(modalContext);
                _showStashSelectionDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddModel(BuildContext context, UserSession session) {
    final count = context.read<HomeCubit>().projectCount;
    final limit = session.limit;

    if (limit != null && count >= limit) {
      showDialog(
        context: context,
        builder: (dialogContext) => LimitDialog(
          title: S.of(context).limitReached,
          message: S.of(context).guestLimitMessage(limit),
          actionLabel: S.of(context).register,
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen(isRegister: true)),
            );
          },
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (childContext) => BlocProvider.value(
          value: context.read<HomeCubit>(),
          child: const AddModelScreen(),
        ),
      ),
    );
  }

  void _showStashSelectionDialog(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    final stashProjects = homeCubit.state.maybeMap(
      loaded: (s) => s.projects.where((p) => p.status == 'GARDEROBA').toList(),
      orElse: () => [],
    );

    if (stashProjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).noModelsInStash)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  S.of(context).selectFromStashTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.navyBlue,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: stashProjects.length,
                  itemBuilder: (context, index) {
                    final model = stashProjects[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AppImage(
                          imageUrl: model.mainImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        model.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navyBlue),
                      ),
                      subtitle: Text(model.scale),
                      onTap: () => _moveModelToWorkshop(context, model, homeCubit),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveModelToWorkshop(BuildContext context, dynamic model, HomeCubit cubit) async {
    Navigator.pop(context); // Close selection sheet
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).movingFromStashToWorkshop)),
    );

    final updated = (model as ModelProject).copyWith(
      status: 'WARSZTAT',
      createdAt: DateTime.now(),
    );
    
    await cubit.updateProject(updated);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).movedToWorkshop)),
      );
    }
  }

  Widget _buildGrid(BuildContext context, List<dynamic> projects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHeader(context, projects.length),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.98,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final model = projects[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelDetailScreen(
                          projectId: model.id,
                          title: model.title,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<HomeCubit>().loadProjects();
                    }
                  },
                  onLongPress: () {
                    _showDeleteConfirmation(context, model.id, model.title);
                  },
                  child: ModelCard(
                    title: model.title,
                    scale: model.scale,
                    progress: model.progress,
                    status: model.status,
                    imageUrl: model.mainImageUrl,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return BlocBuilder<SessionCubit, UserSession>(
      builder: (context, session) {
        final limit = session.limit;
        final isGuest = session.isAnonymous;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).homeTitle, // L10N
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (limit != null)
                    Text(
                      S.of(context).activeProjectsCount(count, limit), // L10N
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isGuest && count >= limit ? AppColors.red : AppColors.grey,
                            fontWeight: isGuest ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                ],
              ),
            ),
            if (isGuest)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen(isRegister: true)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    S.of(context).register, // L10N
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (dialogContext) => LimitDialog(
        title: S.of(context).deleteProjectTitle, // L10N
        message: S.of(context).deleteProjectConfirm(title), // L10N
        actionLabel: S.of(context).deletePermanently, // L10N
        onAction: () {
          context.read<HomeCubit>().deleteProject(id);
        },
      ),
    );
  }
}
