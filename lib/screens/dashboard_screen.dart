import 'package:financeapps/screens/statistik.dart';
import 'package:financeapps/widgets/empty_state.dart';
import 'package:financeapps/widgets/floatingnav.dart';
import 'package:financeapps/widgets/glass_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/glass.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';
import 'detail_transaction_screen.dart';
import 'login_screen.dart';
import 'profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = AuthService();
  late final Stream<List<TransactionModel>> _stream;
  String _nama = '';
  int _tab = 0;
  int _bar = 6; // batang grafik terpilih (6 = hari ini)

  @override
  void initState() {
    super.initState();
    _stream = TransactionService().streamTransactions();
    _auth.getNama().then((nama) {
      if (mounted) setState(() => _nama = nama);
    });
  }

  Future<void> _logout() async {
    final yes = await CustomDialog.confirm(
      context,
      title: 'Keluar dari akun?',
      message: 'Kamu perlu masuk lagi untuk membuka catatanmu.',
      confirmText: 'Keluar',
      destructive: true,
    );
    if (!yes) return;
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openAdd([String? tipe]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(initialTipe: tipe),
      ),
    );
  }

  Future<void> _openProfile(List<TransactionModel> list) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen(transactions: list)),
    );
    if (!mounted) return;
    final nama = await _auth.getNama();
    if (mounted) setState(() => _nama = nama);
  }

  void _openDetail(TransactionModel t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailTransactionScreen(transaction: t),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.deep,
        body: GlassBackground(
          child: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: StreamBuilder<List<TransactionModel>>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Data belum bisa dimuat',
                        message:
                            'Periksa koneksi internetmu, lalu buka ulang aplikasi.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColor.volt),
                      );
                    }

                    final list = snapshot.data!;
                    if (_tab == 1) return StatisticsScreen(transactions: list);
                    return _buildHome(list);
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Center(
                      child: FloatingNav(
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                        onAdd: _openAdd,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(List<TransactionModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final awalBulanIni = DateTime(now.year, now.month, 1);
    final awalBulanLalu = DateTime(now.year, now.month - 1, 1);

    double masuk = 0;
    double keluar = 0;
    double keluarBulanIni = 0;
    double keluarBulanLalu = 0;
    final harian = List<double>.filled(7, 0); // 7 hari terakhir, [6] = hari ini

    for (final t in list) {
      if (t.isPemasukan) {
        masuk += t.nominal;
      } else {
        keluar += t.nominal;
        if (!t.tanggal.isBefore(awalBulanIni)) {
          keluarBulanIni += t.nominal;
        } else if (!t.tanggal.isBefore(awalBulanLalu)) {
          keluarBulanLalu += t.nominal;
        }
        final hari = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
        final selisih = today.difference(hari).inDays;
        if (selisih >= 0 && selisih < 7) harian[6 - selisih] += t.nominal;
      }
    }

    final hariLabel = [
      for (var i = 6; i >= 0; i--)
        DateFormat('E', 'id_ID')
            .format(DateTime(today.year, today.month, today.day - i)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      children: [
        _buildTopBar(list),
        const SizedBox(height: 26),
        _buildBalance(masuk - keluar, list.length),
        const SizedBox(height: 26),
        Row(
          children: [
            const Text(
              'Riwayat transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${list.length} transaksi',
              style: const TextStyle(color: AppColor.onGlassMuted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          const GlassCard(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Belum ada transaksi',
              message: 'Ketuk tombol + untuk mencatat transaksi pertamamu.',
            ),
          )
        else
          _buildList(list),
        const SizedBox(height: 26),
        _buildChartCard(keluarBulanIni, keluarBulanLalu, harian, hariLabel),
      ],
    );
  }

  // Avatar + sapaan di kiri (ketuk untuk buka profil), tombol keluar di kanan.
  Widget _buildTopBar(List<TransactionModel> list) {
    final initial = _nama.isEmpty ? '?' : _nama.substring(0, 1).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openProfile(list),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE6FF8A),
                        AppColor.volt,
                        Color(0xFF9EDB5E),
                      ],
                    ),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColor.forest,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nama.isEmpty ? 'Halo,' : 'Halo, $_nama',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Lihat profil',
                        style: TextStyle(
                          color: AppColor.onGlassMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _logout,
          child: const Tooltip(
            message: 'Keluar',
            child: GlassCard(
              radius: 22,
              padding: EdgeInsets.all(11),
              child: Icon(Icons.logout_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // Kartu saldo: lime mengkilap seperti kartu di desain referensi,
  // berisi saldo besar dan dua tombol aksi.
  Widget _buildBalance(double saldo, int jumlah) {
    final bulan = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
    const teks = AppColor.forest;
    const teksRedup = Color(0xB30B3B2E);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9FF9A), AppColor.volt, Color(0xFF92D85C)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40D2F55A),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // kilap diagonal di sudut kiri atas
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x59FFFFFF), Color(0x00FFFFFF)],
                      stops: [0.0, 0.45],
                    ),
                  ),
                ),
              ),
            ),
            // lingkaran lembut di kanan atas
            Positioned(
              top: -50,
              right: -40,
              child: IgnorePointer(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x26FFFFFF),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Saldo tersedia',
                        style: TextStyle(
                          color: teksRedup,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1F0B3B2E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          bulan,
                          style: const TextStyle(
                            color: teks,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Formatter.rupiah(saldo),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: teks,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$jumlah transaksi tercatat',
                    style: const TextStyle(color: teksRedup, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _pill(
                          label: 'Pemasukan',
                          icon: Icons.south_west_rounded,
                          filled: true,
                          onTap: () => _openAdd(TransactionModel.pemasukan),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _pill(
                          label: 'Pengeluaran',
                          icon: Icons.north_east_rounded,
                          filled: false,
                          onTap: () => _openAdd(TransactionModel.pengeluaran),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tombol di atas kartu lime: terisi hijau tua, atau transparan putih.
  Widget _pill({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final fg = filled ? Colors.white : AppColor.forest;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: filled ? AppColor.forest : const Color(0x4DFFFFFF),
        border: filled ? null : Border.all(color: const Color(0x590B3B2E)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu grafik: pengeluaran bulan ini + batang 7 hari terakhir.
  Widget _buildChartCard(
    double bulanIni,
    double bulanLalu,
    List<double> harian,
    List<String> hariLabel,
  ) {
    String? persen;
    if (bulanLalu > 0) {
      final pct = ((bulanIni - bulanLalu) / bulanLalu * 100).round();
      persen = '${pct >= 0 ? '+' : ''}$pct%';
    }

    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pengeluaran bulan ini',
                      style: TextStyle(
                        color: AppColor.onGlassMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatter.rupiah(bulanIni),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (persen != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33D2F55A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              persen,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColor.volt,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '7 hari',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassBars(
            values: harian,
            labels: hariLabel,
            selected: _bar,
            onSelect: (i) => setState(() => _bar = i),
            format: Formatter.rupiah,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<TransactionModel> list) {
    final groups = <DateTime, List<TransactionModel>>{};
    for (final t in list) {
      final key = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
      groups.putIfAbsent(key, () => []).add(t);
    }
    final keys = groups.keys.toList();

    return GlassCard(
      radius: 28,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (final k in keys) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(k),
                    style: const TextStyle(
                      color: AppColor.onGlassMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < groups[k]!.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 76,
                    endIndent: 16,
                    color: Color(0x1FFFFFFF),
                  ),
                TransactionCard(
                  transaction: groups[k]![i],
                  onTap: () => _openDetail(groups[k]![i]),
                ),
              ],
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}