import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_color.dart';

/// Latar hijau bergradasi dengan dua cahaya lembut (lime di kanan atas,
/// hijau terang di kiri bawah) supaya kartu kaca punya sesuatu untuk di-blur.
class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColor.deep, AppColor.emerald, AppColor.leaf],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -70,
          child: IgnorePointer(child: _glow(300, AppColor.volt, 0.30)),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: IgnorePointer(
            child: _glow(380, const Color(0xFF3DBB6A), 0.38),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  static Widget _glow(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withAlpha((alpha * 255).round()),
            color.withAlpha(0),
          ],
        ),
      ),
    );
  }
}

/// Kartu kaca: blur latar, gradasi putih transparan (terang di kiri atas),
/// dan garis tepi tipis supaya terlihat mengkilap.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final List<Color>? colors;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 26,
    this.blur = 18,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors ?? const [AppColor.glassHi, AppColor.glassLo],
            ),
            border: Border.all(color: AppColor.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}