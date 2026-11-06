import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';

/// Satu baris transaksi. Dipakai di dalam kartu kaca di dashboard.
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final accent =
        t.isPemasukan ? AppColor.incomeOnDark : AppColor.expenseOnDark;
    final tint = t.isPemasukan ? AppColor.incomeTint : AppColor.expenseTint;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColor.glassBorder),
              ),
              child: Icon(
                t.isPemasukan
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    Formatter.tanggal(t.tanggal),
                    style: const TextStyle(
                      color: AppColor.onGlassMuted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Formatter.rupiahBertanda(t.nominal, t.tipe),
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}