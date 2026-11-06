import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_color.dart';

/// Pilihan Pengeluaran / Pemasukan. Yang dipilih terisi penuh warnanya.
class TypeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Option(
            label: TransactionModel.pengeluaran,
            icon: Icons.arrow_upward_rounded,
            selected: value == TransactionModel.pengeluaran,
            color: AppColor.expense,
            onTap: () => onChanged(TransactionModel.pengeluaran),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Option(
            label: TransactionModel.pemasukan,
            icon: Icons.arrow_downward_rounded,
            selected: value == TransactionModel.pemasukan,
            color: AppColor.income,
            onTap: () => onChanged(TransactionModel.pemasukan),
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : AppColor.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColor.line,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColor.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}