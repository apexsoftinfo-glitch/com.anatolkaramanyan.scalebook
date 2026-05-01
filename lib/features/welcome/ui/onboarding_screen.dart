import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design_system/app_colors.dart';
import '../../profiles/models/profile_model.dart';
import '../../session/domain/repositories/session_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'CZYSTY WARSZTAT', // L10N
      description: 'Twoja cyfrowa przestrzeń do dokumentowania każdego szczegółu Twoich modeli.', // L10N
      icon: Icons.grid_view_rounded,
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingData(
      title: 'DZIENNIK KROK PO KROKU', // L10N
      description: 'Rób zdjęcia i notatki z każdego etapu budowy. Nigdy nie zapomnij, jak pomalowałeś ten silnik.', // L10N
      icon: Icons.history_edu_rounded,
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingData(
      title: 'PROFESJONALNE PORTFOLIO', // L10N
      description: 'Eksportuj swoje gotowe modele do pięknych kolarzy gotowych do udostępnienia.', // L10N
      icon: Icons.auto_awesome_motion_rounded,
      imagePath: 'assets/images/onboarding_bg.png',
    ),
    OnboardingData(
      title: 'LOKALNIE I BEZPIECZNIE', // L10N
      description: 'Wszystko zostaje na Twoim urządzeniu. Eksportuj jako ZIP dla łatwej kopii zapasowej.', // L10N
      icon: Icons.security_rounded,
      imagePath: 'assets/images/workbench_bg.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Dynamic)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: SizedBox.expand(
                key: ValueKey(_pages[_currentPage].imagePath),
                child: Image.asset(
                  _pages[_currentPage].imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Dark Overlay for better readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                _buildBottomControls(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.3), width: 2),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(data.icon, size: 80, color: AppColors.navyBlue),
                  const SizedBox(height: 24),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyBlue,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDotsIndicator(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      children: List.generate(
        _pages.length,
        (index) => Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.red : Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentPage == _pages.length - 1;
    return ElevatedButton(
      onPressed: () {
        if (isLast) {
          _completeOnboarding();
        } else {
          _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(
        isLast ? 'ZACZYNAMY' : 'DALEJ', // L10N
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final repo = GetIt.I<SessionRepository>();
    final userId = repo.current.userId;
    if (userId == null) return;

    await repo.updateProfile(ProfileModel(
      id: userId,
      firstName: 'Modelarz',
      hasCompletedOnboarding: true,
    ));
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });
}
