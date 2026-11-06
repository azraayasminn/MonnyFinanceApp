import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import 'glass.dart';

/// Navigasi melayang berbentuk pil kaca: Beranda, tombol tambah di tengah, Statistik.
class FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;

  const FloatingNav({
    super.key,
    required this.index,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 40,
      blur: 22,
      padding: const EdgeInsets.all(8),
      colors: const [Color(0x66072E24), Color(0x99041A14)],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(Icons.home_rounded, 'Beranda', 0),
          const SizedBox(width: 10),
          Tooltip(
            message: 'Catat transaksi',
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE6FF8A), AppColor.volt, Color(0xFF9EDB5E)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x73D2F55A),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColor.forest,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _item(Icons.bar_chart_rounded, 'Statistik', 1),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final selected = index == i;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 26,
            color: selected ? AppColor.forest : const Color(0xB3FFFFFF),
          ),
        ),
      ),
    );
  }
}