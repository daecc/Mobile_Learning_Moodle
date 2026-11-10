import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/sync_coordinator.dart';
import '../widgets/liquid_glass_nav_bar.dart';
import 'courses_screen.dart';
import 'gamification_screen.dart';
import 'metacognitive_screen.dart';
import 'tutor_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  static _MainNavigationScreenState? _activeState;

  /// Permite cambiar a cualquier pestaña principal desde pantallas hijas
  static void switchToTab(BuildContext context, int index) {
    if (_activeState != null && _activeState!.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      _activeState!.switchTab(index);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    MainNavigationScreen._activeState = this;
  }

  @override
  void dispose() {
    if (MainNavigationScreen._activeState == this) {
      MainNavigationScreen._activeState = null;
    }
    super.dispose();
  }

  void switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
    // Al cambiar de pestaña, asegurar que los datos locales en memoria se mantengan sincronizados
    if (index == 0 || index == 2 || index == 3) {
      AppSyncCoordinator.reloadLocalState(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          CoursesScreen(),
          TutorScreen(isTab: true),
          MetacognitiveScreen(isTab: true),
          GamificationScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: _currentIndex,
        onTap: switchTab,
      ),
    );
  }
}
