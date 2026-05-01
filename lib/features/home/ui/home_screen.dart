import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<HomeCubit>()..loadProjects(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/app_logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Text('SCALEBOOK'), // L10N
            ],
          ),
          actions: [
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
                loaded: (s) => _buildGrid(context, s.projects),
                error: (s) => Center(child: Text(s.message)),
                orElse: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        floatingActionButton: BlocBuilder<SessionCubit, UserSession>(
          builder: (context, session) {
            return FloatingActionButton(
              onPressed: () {
                final count = context.read<HomeCubit>().projectCount;
                final limit = session.limit;

                if (limit != null && count >= limit) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => LimitDialog(
                      title: 'LIMIT OSIĄGNIĘTY', // L10N
                      message:
                          'Jako Gość możesz mieć maksymalnie $limit projekty. Załóż konto, aby zyskać nielimitowane miejsce na warsztacie!', // L10N
                      actionLabel: 'STWÓRZ KONTO', // L10N
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
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
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
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final model = projects[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelDetailScreen(
                          projectId: model.id,
                          title: model.title,
                        ),
                      ),
                    );
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
                    'TWÓJ WARSZTAT', // L10N
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (limit != null)
                    Text(
                      '$count / $limit aktywne projekty', // L10N
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
                  child: const Text(
                    'ZAREJESTRUJ SIĘ', // L10N
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
        title: 'USUŃ PROJEKT', // L10N
        message: 'Czy na pewno chcesz usunąć projekt "$title"? Pamiętaj, że nie będzie możliwości przywrócenia projektu ani jego historii budowy.', // L10N
        actionLabel: 'USUŃ NA ZAWSZE', // L10N
        onAction: () {
          context.read<HomeCubit>().deleteProject(id);
        },
      ),
    );
  }
}
