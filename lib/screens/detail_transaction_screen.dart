import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/app_color.dart';
import '../utils/formatter.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass.dart';

class DetailTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionScreen({super.key, required this.transaction});

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TransactionService();
  late final TextEditingController _nominal;
  late final TextEditingController _catatan;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nominal = TextEditingController(
      text: widget.transaction.nominal.toStringAsFixed(0),
    );
    _catatan = TextEditingController(text: widget.transaction.catatan);
  }

  @override
  void dispose() {
    _nominal.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final transactionId = widget.transaction.id;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.update(
        transactionId,
        nominal: double.parse(_nominal.text),
        catatan: _catatan.text.trim(),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan')),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Perubahan belum tersimpan. Coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final yes = await CustomDialog.confirm(
      context,
      title: 'Hapus transaksi ini?',
      message: 'Data yang dihapus tidak bisa dikembalikan.',
      confirmText: 'Hapus',
      destructive: true,
    );
    if (!yes) return;
    if (!mounted) return;
    final transactionId = widget.transaction.id;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.delete(transactionId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi dihapus')),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi belum terhapus. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final accent =
        t.isPemasukan ? AppColor.incomeOnDark : AppColor.expenseOnDark;
    final tint = t.isPemasukan ? AppColor.incomeTint : AppColor.expenseTint;

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummary(t, accent, tint),
                        const SizedBox(height: 26),
                        const Text(
                          'Ubah nominal atau catatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Form(
                          key: _formKey,
                          child: GlassCard(
                            radius: 28,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                CustomTextField(
                                  glass: true,
                                  controller: _nominal,
                                  label: 'Nominal',
                                  prefixText: 'Rp ',
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Nominal wajib diisi';
                                    }
                                    if ((double.tryParse(v) ?? 0) <= 0) {
                                      return 'Nominal harus lebih dari 0';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                CustomTextField(
                                  glass: true,
                                  controller: _catatan,
                                  label: 'Catatan',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                        const SizedBox(height: 6),
                        Center(
                          child: TextButton(
                            onPressed: _delete,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColor.expenseOnDark,
                            ),
                            child: const Text('Hapus transaksi'),
                          ),
                        ),
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
            'Detail transaksi',
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

  // Ringkasan transaksi: tipe, nominal besar, judul, dan waktu.
  Widget _buildSummary(TransactionModel t, Color accent, Color tint) {
    return GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(20),
      colors: const [Color(0x40FFFFFF), Color(0x0FFFFFFF)],
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.isPemasukan
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 14,
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.tipe,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatter.rupiahBertanda(t.nominal, t.tipe),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.judul,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatter.tanggal(t.tanggal),
              style: const TextStyle(
                color: AppColor.onGlassMuted,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
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
                : const Text(
                    'Simpan perubahan',
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