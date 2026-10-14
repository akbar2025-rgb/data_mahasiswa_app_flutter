import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/transitions.dart';
import 'list_data_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        fadeRoute(const ListDataScreen(), const RouteSettings(name: '/list')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC9D8F5), width: 8),
                  color: const Color(0xFFE4EBFB),
                ),
                child: Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'UNIVERSITAS NEGERI NGAWI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w700,
                fontSize: 19,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(width: 72, height: 3, color: AppColors.primary),
            const Spacer(flex: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.softBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Versi 1.0.0',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '\u00a9 2026 All Rights Reserved',
              style: TextStyle(color: Color(0xFF9AA5B8), fontSize: 13),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
