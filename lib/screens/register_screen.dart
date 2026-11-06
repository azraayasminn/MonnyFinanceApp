import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../utils/app_color.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        _namaC.text.trim(),
        _emailC.text.trim(),
        _passC.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.pesanError(e));
    } catch (e) {
      _showError(AuthService.pesanError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColor.deep,
        body: GlassBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBack(),
                  const SizedBox(height: 28),
                  _buildLogo(),
                  const SizedBox(height: 22),
                  const Text(
                    'Buat akun baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gratis, dan datamu tersimpan aman di akunmu.',
                    style: TextStyle(
                      color: AppColor.onGlassMuted,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Form(
                    key: _formKey,
                    child: GlassCard(
                      radius: 30,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CustomTextField(
                            glass: true,
                            controller: _namaC,
                            label: 'Nama',
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            glass: true,
                            controller: _emailC,
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              final text = v?.trim() ?? '';
                              if (text.isEmpty) return 'Email wajib diisi';
                              if (!text.contains('@') || !text.contains('.')) {
                                return 'Format email belum benar';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            glass: true,
                            controller: _passC,
                            label: 'Kata sandi',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Kata sandi minimal 6 karakter'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            glass: true,
                            controller: _confirmC,
                            label: 'Ulangi kata sandi',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) => v != _passC.text
                                ? 'Kata sandi tidak sama'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubmit(),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun?',
                        style: TextStyle(color: AppColor.onGlassMuted),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.volt,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Tooltip(
        message: 'Kembali',
        child: GlassCard(
          radius: 22,
          padding: EdgeInsets.all(11),
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // Logo dompet di kotak lime mengkilap, seperti kartu di layar beranda.
  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9FF9A), AppColor.volt, Color(0xFF92D85C)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59D2F55A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: AppColor.forest,
        size: 30,
      ),
    );
  }

  Widget _buildSubmit() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6FF8A), AppColor.volt, Color(0xFF9EDB5E)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59D2F55A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _loading ? null : _register,
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColor.forest,
                    ),
                  )
                : const Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.forest,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}