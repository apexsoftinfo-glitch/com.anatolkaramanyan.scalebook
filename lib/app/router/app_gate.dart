import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/welcome/ui/onboarding_screen.dart';
import '../../features/session/domain/models/user_session.dart';
import '../../features/session/presentation/cubit/session_cubit.dart';
import '../../features/welcome/ui/welcome_screen.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, UserSession>(
      builder: (context, session) {
        return session.map(
          (s) {
            if (s.needsOnboarding) return const OnboardingScreen();
            if (!s.hasCompletedOnboarding) return const OnboardingScreen();
            return const HomeScreen();
          },
          unauthenticated: (_) => const WelcomeScreen(),
          initializing: (_) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
