import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass.dart';
import '../widgets/type_selector.dart';

class AddTransactionScreen extends StatefulWidget {
  /// Tipe awal: 'Pemasukan' atau 'Pengeluaran'. Kosong = Pengeluaran.
  final String? initialTipe;

  const AddTransactionScreen({super.key, this.initialTipe});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const _cepat = [10000, 20000, 50000, 100000];

  final _formKey = GlobalKey<FormState>();
  final _nominal = TextEditingController();
  final _judul = TextEditingController();
  final _catatan = TextEditingController();
  late String _tipe;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tipe = widget.initialTipe ?? TransactionModel.pengeluaran;
  }

  @override
  void dispose() {
    _nominal.dispose();
    _judul.dispose();
    _catatan.dispose();
    super.dispose();
  }

  void _isiNominal(int v) {
    _nominal.text = '$v';
    _nominal.selection = TextSelection.collapsed(offset: _nominal.text.length);
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await TransactionService().add(
        TransactionModel(
          id: '',
          judul: _judul.text.trim(),
          nominal: double.parse(_nominal.text),
          tipe: _tipe,
          catatan: _catatan.text.trim(),
          tanggal: DateTime.now(),
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi disimpan')),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi belum tersimpan. Coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masuk = _tipe == TransactionModel.pemasukan;
    final warna = masuk ? AppColor.volt : AppColor.expenseOnDark;

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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TypeSelector(
                            value: _tipe,
                            onChanged: (v) => setState(() => _tipe = v),
                          ),
                          const SizedBox(height: 18),
                          _buildNominalCard(warna),
                          const SizedBox(height: 16),
                          GlassCard(
                            radius: 28,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                CustomTextField(
                                  glass: true,
                                  controller: _judul,
                                  label: 'Judul transaksi',
                                  textInputAction: TextInputAction.next,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Judul wajib diisi'
                                          : null,
                                ),
                                const SizedBox(height: 14),
                                CustomTextField(
                                  glass: true,
                                  controller: _catatan,
                                  label: 'Catatan (opsional)',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSaveButton(masuk, warna),
                        ],
                      ),
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
            'Catat transaksi',
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

  // Nominal besar di tengah kartu, dengan pilihan nominal cepat di bawahnya.
  Widget _buildNominalCard(Color warna) {
    final aktif = int.tryParse(_nominal.text);

    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      colors: const [Color(0x40FFFFFF), Color(0x0FFFFFFF)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nominal',
            style: TextStyle(color: AppColor.onGlassMuted, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: warna,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _nominal,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  cursorColor: AppColor.volt,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Color(0x4DFFFFFF)),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorStyle: TextStyle(color: AppColor.expenseOnDark),
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                    if ((double.tryParse(v) ?? 0) <= 0) {
                      return 'Nominal harus lebih dari 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in _cepat)
                GestureDetector(
                  onTap: () => _isiNominal(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: aktif == v
                          ? warna
                          : const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: aktif == v ? warna : AppColor.glassBorder,
                      ),
                    ),
                    child: Text(
                      Formatter.rupiah(v),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: aktif == v ? AppColor.forest : Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool masuk, Color warna) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: warna,
        boxShadow: [
          BoxShadow(
            color: warna.withAlpha(90),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _loading ? null : _save,
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
                : Text(
                    masuk ? 'Simpan pemasukan' : 'Simpan pengeluaran',
                    style: const TextStyle(
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