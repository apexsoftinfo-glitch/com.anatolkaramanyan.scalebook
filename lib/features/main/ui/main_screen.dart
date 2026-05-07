import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/ui/home_screen.dart';
import '../../stash/ui/stash_screen.dart';
import '../../notes/ui/notes_screen.dart';
import '../../home/presentation/cubit/home_cubit.dart';
import '../../notes/presentation/cubit/notes_cubit.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../../session/domain/models/user_session.dart';
import '../../../core/design_system/app_colors.dart';
import '../../showcase/ui/showcase_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ShowcaseScreen(),
    const NotesScreen(),
    const StashScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, UserSession>(
      listener: (context, session) {
        // Trigger reload when session is established
        if (session.userId != null) {
          context.read<HomeCubit>().loadProjects();
          context.read<NotesCubit>().loadNotes();
        }
      },
      child: Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.navyBlue,
        selectedItemColor: AppColors.red,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: S.of(context).pulpit, // L10N
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            activeIcon: const Icon(Icons.emoji_events),
            label: S.of(context).showcase,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.note_outlined),
            activeIcon: const Icon(Icons.note),
            label: S.of(context).notes, // L10N
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shelves),
            label: S.of(context).stash, // L10N
          ),
        ],
      ),
      ),
    );
  }
}
