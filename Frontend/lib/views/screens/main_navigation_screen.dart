import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/courses_viewmodel.dart';
import '../widgets/liquid_glass_nav_bar.dart';
import 'courses_screen.dart';
import 'gamification_screen.dart';
import 'metacognitive_screen.dart';
import 'tutor_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
