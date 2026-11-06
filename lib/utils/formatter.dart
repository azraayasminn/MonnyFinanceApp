import 'package:intl/intl.dart';

class Formatter {
  Formatter._();

  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String rupiah(num value) => _rupiah.format(value);

  static String rupiahBertanda(num value, String tipe) {
    final tanda = tipe == 'Pemasukan' ? '+' : '-';
    return '$tanda${rupiah(value)}';
  }

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