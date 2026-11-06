import 'package:flutter/material.dart';
import '../utils/app_color.dart';

/// Grafik batang kaca. Batang terpilih berwarna lime dan menampilkan
/// gelembung nominal di atasnya. Ketuk batang untuk memilih.
class GlassBars extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  final String Function(double) format;
  final double height;

  const GlassBars({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelect,
    required this.format,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    const labelH = 20.0;
    const tipH = 32.0;
    const gap = 8.0;
    final barArea = height - labelH - tipH - gap;
    final maxV = values.fold<double>(0, (m, v) => v > m ? v : m);
    final n = values.length;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: tipH,
                      child: i == selected
                          ? OverflowBox(
                              maxWidth: 130,
                              alignment: i == 0
                                  ? Alignment.centerLeft
                                  : i == n - 1
                                      ? Alignment.centerRight
                                      : Alignment.center,
                              child: _tip(format(values[i])),
                            )
                          : null,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      height: values[i] <= 0 || maxV <= 0
                          ? 8
                          : 14 + (barArea - 14) * (values[i] / maxV),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: i == selected
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColor.volt, Color(0xFF8FD65A)],
                              )
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x38FFFFFF), Color(0x0FFFFFFF)],
                              ),
                        border: i == selected
                            ? null
                            : Border.all(color: const Color(0x1FFFFFFF)),
                      ),
                    ),
                    const SizedBox(height: gap),
                    SizedBox(
                      height: labelH - 4,
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              i == selected ? FontWeight.w700 : FontWeight.w500,
                          color: i == selected
                              ? Colors.white
                              : AppColor.onGlassMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3A2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.glassBorder),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}