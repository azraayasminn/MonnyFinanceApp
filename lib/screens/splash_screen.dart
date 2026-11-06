import 'package:flutter/material.dart';
import '../brandmark.dart';
import '../services/auth_service.dart';
import '../utils/app_color.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _next();
  }

  Future<void> _next() async {
    // Logo tampil minimal 1,5 detik sambil menunggu sesi login dipulihkan.
    final results = await Future.wait<dynamic>([
      AuthService().authChanges.first,
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (!mounted) return;
    final loggedIn = results.first != null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColor.glass,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.hero),
        child: Stack(
          children: [
            Positioned(right: -60, top: -60, child: _circle(220)),
            Positioned(left: -50, bottom: -70, child: _circle(200)),
            const Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandMark(size: 92, inverted: true),
                    SizedBox(height: 24),
                    Text(
                      'Monny',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Money Smart, Fresh Start."',
                      style: TextStyle(
                        color: AppColor.onPrimaryMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}