import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

/// CRUD transaksi di users/{uid}/transactions.
class TransactionService {
  CollectionReference<Map<String, dynamic>> get _col {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions');
  }

  Stream<List<TransactionModel>> streamTransactions() {
    return _col.orderBy('tanggal', descending: true).snapshots().map(
          (snap) =>
              snap.docs.map((d) => TransactionModel.fromFirestore(d)).toList(),
        );
  }

  Future<void> add(TransactionModel transaksi) {
    return _col.add(transaksi.toMap());
  }

  Future<void> update(
    String id, {
    required double nominal,
    required String catatan,
  }) {
    return _col.doc(id).update({'nominal': nominal, 'catatan': catatan});
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}