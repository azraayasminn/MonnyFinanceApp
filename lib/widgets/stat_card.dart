import 'package:flutter/material.dart';
import '../utils/app_color.dart';

/// Kotak kecil berisi ikon, label, dan angka (Pemasukan / Pengeluaran).
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color accent;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.muted,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}