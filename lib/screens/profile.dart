import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  /// Dipakai untuk ringkasan di kartu atas. Boleh kosong.
  final List<TransactionModel> transactions;

  const ProfileScreen({super.key, this.transactions = const []});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  String _nama = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _auth.getNama().then((nama) {
      if (!mounted) return;
      setState(() {
        _nama = nama;
        _namaC.text = nama;
      });
    });
  }

  @override
  void dispose() {
    _namaC.dispose();
    super.dispose();
  }

  Future<void> _saveNama() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final baru = _namaC.text.trim();
    setState(() => _saving = true);
    try {
      await _auth.updateNama(baru);
      if (!mounted) return;
      setState(() => _nama = baru);
      messenger.showSnackBar(const SnackBar(content: Text('Nama diperbarui')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AuthService.pesanError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? '-';
    final dibuat = user?.metadata.creationTime;
    final bergabung = dibuat == null
        ? '-'
        : DateFormat('d MMMM yyyy', 'id_ID').format(dibuat);

    double masuk = 0;
    double keluar = 0;
    for (final t in widget.transactions) {
      if (t.isPemasukan) {
        masuk += t.nominal;
      } else {
        keluar += t.nominal;
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.deep,
        body: GlassBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        _buildIdentity(email),
                        const SizedBox(height: 24),
                        _buildSummary(widget.transactions.length, masuk, keluar),
                        const SizedBox(height: 16),
                        _buildInfo(email, bergabung),
                        const SizedBox(height: 16),
                        _buildEditName(),
                        const SizedBox(height: 22),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Tooltip(
              message: 'Kembali',
              child: GlassCard(
                radius: 22,
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Avatar besar berinisial, nama, dan email.
  Widget _buildIdentity(String email) {
    final initial = _nama.isEmpty ? '?' : _nama.substring(0, 1).toUpperCase();

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FF8A), AppColor.volt, Color(0xFF9EDB5E)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x59D2F55A),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColor.forest,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _nama.isEmpty ? '...' : _nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColor.onGlassMuted, fontSize: 14),
        ),
      ],
    );
  }

  // Tiga angka ringkas: jumlah transaksi, total masuk, total keluar.
  Widget _buildSummary(int jumlah, double masuk, double keluar) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      colors: const [Color(0x40FFFFFF), Color(0x0FFFFFFF)],
      child: IntrinsicHeight(
        child: Row(
          children: [
            _stat('Transaksi', '$jumlah', Colors.white),
            _divider(),
            _stat('Pemasukan', Formatter.rupiah(masuk), AppColor.incomeOnDark),
            _divider(),
            _stat('Pengeluaran', Formatter.rupiah(keluar),
                AppColor.expenseOnDark),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColor.onGlassMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const VerticalDivider(
      width: 1,
      thickness: 1,
      color: Color(0x1FFFFFFF),
    );
  }

  Widget _buildInfo(String email, String bergabung) {
    return GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Column(
        children: [
          _infoRow(Icons.mail_outline_rounded, 'Email', email),
          const Divider(height: 1, color: Color(0x1FFFFFFF)),
          _infoRow(Icons.event_rounded, 'Bergabung sejak', bergabung),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0x1FFFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.volt, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColor.onGlassMuted,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditName() {
    return Form(
      key: _formKey,
      child: GlassCard(
        radius: 28,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah nama',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              glass: true,
              controller: _namaC,
              label: 'Nama',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.done,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6FF8A), AppColor.volt, Color(0xFF9EDB5E)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59D2F55A),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _saving ? null : _saveNama,
          child: Center(
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColor.forest,
                    ),
                  )
                : const Text(
                    'Simpan nama',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColor.forest,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: AppColor.expenseTint,
        shape: StadiumBorder(
          side: BorderSide(
            color: AppColor.expenseOnDark.withAlpha(110),
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _logout,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  color: AppColor.expenseOnDark, size: 20),
              SizedBox(width: 10),
              Text(
                'Keluar dari akun',
                style: TextStyle(
                  color: AppColor.expenseOnDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}