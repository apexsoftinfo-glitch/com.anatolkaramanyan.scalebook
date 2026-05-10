import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/main/ui/main_screen.dart';
import '../../features/welcome/ui/onboarding_screen.dart';
import '../../features/session/domain/models/user_session.dart';
import '../../features/session/presentation/cubit/session_cubit.dart';
import '../../features/welcome/ui/welcome_screen.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/notes/presentation/cubit/notes_cubit.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, UserSession>(
      listenWhen: (previous, current) => previous.userId != current.userId,
      listener: (context, session) {
        // When user changes (login/logout/switch), reset and reload data
        context.read<HomeCubit>().clear();
        context.read<NotesCubit>().clear();
        
        if (session.userId != null) {
          context.read<HomeCubit>().loadProjects();
          context.read<NotesCubit>().loadNotes();
        }
      },
      child: BlocBuilder<SessionCubit, UserSession>(
        builder: (context, session) {
          return session.map(
            (s) {
              if (s.needsOnboarding) return const OnboardingScreen();
              if (!s.hasCompletedOnboarding) return const OnboardingScreen();
              return const MainScreen();
            },
            unauthenticated: (_) => const WelcomeScreen(),
            initializing: (_) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
