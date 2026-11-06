import 'package:flutter/material.dart';

/// Semua warna aplikasi ada di sini. Tema: hijau tua, lembut, minimalis.
class AppColor {
  AppColor._();

  // Dasar
  static const Color ink = Color(0xFF12241E); // teks utama
  static const Color forest = Color(0xFF0B3B2E); // hijau tua (judul, panel, tombol)
  static const Color paper = Color(0xFFFFFFFF); // kartu
  static const Color background = Color(0xFFEAF3EE); // latar layar
  static const Color fill = Color(0xFFF3F7F5);
  static const Color line = Color.fromARGB(255, 59, 65, 61); // garis pemisah
  static const Color muted = Color(0xFF6F8279); // teks pendukung

  // Warna utama
  static const Color primary = forest;
  static const Color sun = Color(0xFFFFB020);

  // Hijau muda (kartu atas, koin, pil)
  static const Color lime = Color(0xFFB9E08F);
  static const Color limeSoft = Color(0xFFE6F4D3);
  static const Color limeDeep = Color(0xFF7DBE4A);

  // Pemasukan & pengeluaran
  static const Color income = Color(0xFF168A5B);
  static const Color expense = Color(0xFFE5484D);

  // Warna lembut
  static const Color primarySoft = Color(0xFFE1F0E7);
  static const Color incomeSoft = Color(0xFFE1F4EA);
  static const Color expenseSoft = Color(0xFFFDECEC);

  // Aksen pelengkap (ikon Pengeluaran terbesar)
  static const Color orange = Color(0xFFF08A24);
  static const Color orangeSoft = Color(0xFFFFF1E0);
  static const Color violet = Color(0xFF7C5CE0);
  static const Color violetSoft = Color(0xFFEEE9FF);

  // Di atas latar hijau tua
  static const Color onPrimaryMuted = Color(0xFFA9C9BC);
  static const Color glass = Color(0x24FFFFFF); // putih transparan

  // Gradasi (header Masuk/Daftar dan splash)
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B3B2E), Color(0xFF14604B)],
  );

  // ---- Tema glossy (dashboard & statistik) ----
  static const Color volt = Color(0xFFD2F55A); // lime terang untuk tombol utama
  static const Color deep = Color(0xFF072E24);
  static const Color emerald = Color(0xFF0D4F3A);
  static const Color leaf = Color(0xFF1B6B3A);
  static const Color glassHi = Color(0x33FFFFFF); // sisi terang kaca
  static const Color glassLo = Color(0x0DFFFFFF); // sisi redup kaca
  static const Color glassBorder = Color(0x2EFFFFFF);
  static const Color onGlass = Color(0xFFFFFFFF);
  static const Color onGlassMuted = Color(0xB3FFFFFF);
  static const Color incomeOnDark = Color(0xFFB9F27A);
  static const Color expenseOnDark = Color(0xFFFF8F93);
  static const Color incomeTint = Color(0x29B9F27A);
  static const Color expenseTint = Color(0x29FF8F93);
}