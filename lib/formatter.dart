import 'package:intl/intl.dart';

/// Format rupiah dan tanggal.
/// Pastikan initializeDateFormatting('id_ID') sudah dipanggil di main().
class Formatter {
  Formatter._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// 25000 -> "Rp 25.000"
  static String rupiah(num value) => _rupiah.format(value);

  /// Pemasukan -> "+Rp 25.000", Pengeluaran -> "-Rp 25.000"
  static String rupiahBertanda(num value, String tipe) {
    final tanda = tipe == 'Pemasukan' ? '+' : '-';
    return '$tanda${rupiah(value)}';
  }

  /// "Hari ini, 12:30" / "Kemarin, 08:10" / "5 Nov 2026, 19:45"
  static String tanggal(DateTime date) {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);
    final hariItu = DateTime(date.year, date.month, date.day);
    final selisih = hariIni.difference(hariItu).inDays;
    final jam = DateFormat('HH:mm', 'id_ID').format(date);

    if (selisih == 0) return 'Hari ini, $jam';
    if (selisih == 1) return 'Kemarin, $jam';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
  }
}