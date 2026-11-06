import 'package:flutter/material.dart';
import 'utils/app_color.dart';

/// Logo aplikasi. Ganti Icon dengan Image.asset kalau sudah punya logo sendiri.
class BrandMark extends StatelessWidget {
  final double size;
  final bool inverted;

  const BrandMark({super.key, this.size = 52, this.inverted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: inverted ? Colors.white : AppColor.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: inverted ? AppColor.primary : Colors.white,
        size: size * 0.52,
      ),
    );
  }
}