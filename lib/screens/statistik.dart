import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';
import '../widgets/glass.dart';
import '../widgets/glass_bar.dart';

enum StatsPeriod { minggu, bulan, kuartal }

class _Bucket {
  final String label;
  final String title;
  final DateTime start;
  final DateTime end;
  double masuk = 0;
  double keluar = 0;
  final List<TransactionModel> items = [];

  _Bucket({
    required this.label,
    required this.title,
    required this.start,
    required this.end,
  });
}

/// Isi tab Statistik: grafik batang, ringkasan, dan pengeluaran terbesar.
class StatisticsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatsPeriod _period = StatsPeriod.bulan;
  int _selected = 5;

  static String _label(StatsPeriod p) {
    if (p == StatsPeriod.minggu) return 'Minggu';
    if (p == StatsPeriod.bulan) return 'Bulan';
    return 'Kuartal';
  }

  static int _defaultIndex(StatsPeriod p) {
    if (p == StatsPeriod.minggu) return 6;
    if (p == StatsPeriod.bulan) return 5;
    return (DateTime.now().month - 1) ~/ 3;
  }

  List<_Bucket> _buildBuckets() {
    final now = DateTime.now();
    final list = <_Bucket>[];

    if (_period == StatsPeriod.minggu) {
      for (var i = 6; i >= 0; i--) {
        final d = DateTime(now.year, now.month, now.day - i);
        list.add(_Bucket(
          label: DateFormat('E', 'id_ID').format(d),
          title: DateFormat('EEEE, d MMM', 'id_ID').format(d),
          start: d,
          end: DateTime(d.year, d.month, d.day + 1),
        ));
      }
    } else if (_period == StatsPeriod.bulan) {
      for (var i = 5; i >= 0; i--) {
        final m = DateTime(now.year, now.month - i, 1);
        list.add(_Bucket(
          label: DateFormat('MMM', 'id_ID').format(m),
          title: DateFormat('MMMM yyyy', 'id_ID').format(m),
          start: m,
          end: DateTime(m.year, m.month + 1, 1),
        ));
      }
    } else {
      for (var q = 0; q < 4; q++) {
        list.add(_Bucket(
          label: 'K${q + 1}',
          title: 'Kuartal ${q + 1} ${now.year}',
          start: DateTime(now.year, q * 3 + 1, 1),
          end: DateTime(now.year, q * 3 + 4, 1),
        ));
      }
    }

    for (final t in widget.transactions) {
      for (final b in list) {
        if (!t.tanggal.isBefore(b.start) && t.tanggal.isBefore(b.end)) {
          if (t.isPemasukan) {
            b.masuk += t.nominal;
          } else {
            b.keluar += t.nominal;
          }
          b.items.add(t);
          break;
        }
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final buckets = _buildBuckets();
    final index = _selected >= buckets.length ? buckets.length - 1 : _selected;
    final sel = buckets[index];

    final spends = sel.items.where((t) => !t.isPemasukan).toList()
      ..sort((a, b) => b.nominal.compareTo(a.nominal));
    final top = spends.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const Text(
          'Statistik',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildTabs(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_downward_rounded,
                label: 'Pemasukan',
                value: Formatter.rupiah(sel.masuk),
                color: AppColor.incomeOnDark,
                soft: AppColor.incomeTint,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.arrow_upward_rounded,
                label: 'Pengeluaran',
                value: Formatter.rupiah(sel.keluar),
                color: AppColor.expenseOnDark,
                soft: AppColor.expenseTint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
          child: GlassBars(
            values: [for (final b in buckets) b.keluar],
            labels: [for (final b in buckets) b.label],
            selected: index,
            onSelect: (i) => setState(() => _selected = i),
            format: Formatter.rupiah,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pengeluaran · ${sel.title}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (top.isEmpty)
          const SizedBox(
            width: double.infinity,
            child: GlassCard(
              radius: 20,
              padding: EdgeInsets.all(18),
              child: Text(
                'Belum ada pengeluaran di periode ini.',
                style: TextStyle(color: AppColor.onGlassMuted),
              ),
            ),
          )
        else
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: i < top.length
                      ? _SpendCard(transaction: top[i], rank: i)
                      : const SizedBox(),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildTabs() {
    return GlassCard(
      radius: 20,
      blur: 14,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final p in StatsPeriod.values)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _period = p;
                  _selected = _defaultIndex(p);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: _period == p ? AppColor.volt : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _label(p),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _period == p
                            ? AppColor.forest
                            : AppColor.onGlassMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color soft;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.soft,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColor.onGlassMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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

class _SpendCard extends StatelessWidget {
  final TransactionModel transaction;
  final int rank;

  const _SpendCard({required this.transaction, required this.rank});

  @override
  Widget build(BuildContext context) {
    const soft = [
      AppColor.expenseTint,
      Color(0x29FFB066),
      Color(0x29BBA8FF),
    ];
    const strong = [
      AppColor.expenseOnDark,
      Color(0xFFFFB066),
      Color(0xFFBBA8FF),
    ];

    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: soft[rank],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_rounded,
              color: strong[rank],
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatter.rupiah(transaction.nominal),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            transaction.judul,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColor.onGlassMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}