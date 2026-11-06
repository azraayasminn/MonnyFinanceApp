import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Buat akun, lalu simpan profil ke koleksi users/{uid}.
  Future<void> register(String nama, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    if (user == null) return;

    await user.updateDisplayName(nama.trim());
    await _db.collection('users').doc(user.uid).set({
      'nama': nama.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Nama untuk header dashboard: dari Firestore, lalu displayName,
  /// lalu bagian depan email.
  Future<String> getNama() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final nama = (doc.data()?['nama'] ?? '') as String;
      if (nama.isNotEmpty) return nama;
    } catch (_) {
      // lanjut ke cadangan di bawah
    }

    final display = user.displayName ?? '';
    if (display.isNotEmpty) return display;
    final email = user.email ?? '';
    return email.contains('@') ? email.split('@').first : email;
  }

  /// Ubah nama di akun dan di koleksi users/{uid}.
  Future<void> updateNama(String nama) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final baru = nama.trim();
    await user.updateDisplayName(baru);
    await _db.collection('users').doc(user.uid).set(
      {'nama': baru},
      SetOptions(merge: true),
    );
  }

  Future<void> logout() => _auth.signOut();

  static String pesanError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau password salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar.';
        case 'weak-password':
          return 'Password terlalu lemah (minimal 6 karakter).';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti.';
      }
      return e.message ?? 'Terjadi kesalahan.';
    }
    if (e is FirebaseException && e.code == 'permission-denied') {
      return 'Akses database ditolak. Periksa Firestore Rules.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }
}