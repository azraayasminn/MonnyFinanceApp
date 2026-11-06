import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  static const String pemasukan = 'Pemasukan';
  static const String pengeluaran = 'Pengeluaran';

  final String id;
  final String judul;
  final double nominal;
  final String tipe;
  final String catatan;
  final DateTime tanggal;

  const TransactionModel({
    required this.id,
    required this.judul,
    required this.nominal,
    required this.tipe,
    required this.catatan,
    required this.tanggal,
  });

  bool get isPemasukan => tipe == pemasukan;

  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['tanggal'];
    return TransactionModel(
      id: doc.id,
      judul: (data['judul'] ?? '') as String,
      nominal: ((data['nominal'] ?? 0) as num).toDouble(),
      tipe: (data['tipe'] ?? pengeluaran) as String,
      catatan: (data['catatan'] ?? '') as String,
      tanggal: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'nominal': nominal,
      'tipe': tipe,
      'catatan': catatan,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}