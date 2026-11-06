import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_color.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? prefixText;
  final bool isPassword;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  /// true = gaya kaca transparan untuk latar hijau (layar Masuk & Daftar).
  /// false = gaya biasa dari tema global (layar tambah/detail transaksi).
  final bool glass;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.prefixText,
    this.isPassword = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.glass = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return widget.glass ? _buildGlass() : _buildDefault();
  }

  Widget _buildDefault() {
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      obscureText: widget.isPassword && _hide,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: widget.prefixText,
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: AppColor.muted),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _hide
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColor.muted,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
      ),
    );
  }

  // Kolom kaca: isi transparan, garis tepi tipis, label naik ke dalam kolom,
  // dan saat salah: garis tepi + label + pesan berwarna merah muda.
  Widget _buildGlass() {
    return FormField<String>(
      initialValue: widget.controller.text,
      // Selalu cek isi controller, bukan nilai awal FormField, supaya teks yang
      // diisi lewat kode (mis. nama dari Firestore) ikut tervalidasi.
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(widget.controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;
        final accent = hasError ? AppColor.expenseOnDark : null;
        final labelColor = accent ?? AppColor.onGlassMuted;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0x2EFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accent ?? const Color(0x33FFFFFF),
                  width: hasError ? 1.2 : 1,
                ),
              ),
              child: TextField(
                controller: widget.controller,
                autofocus: widget.autofocus,
                obscureText: widget.isPassword && _hide,
                maxLines: widget.isPassword ? 1 : widget.maxLines,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
                onChanged: state.didChange,
                cursorColor: AppColor.volt,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixText: widget.prefixText,
                  prefixStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: widget.icon == null
                      ? null
                      : Icon(widget.icon, color: AppColor.onGlassMuted),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          icon: Icon(
                            _hide
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColor.onGlassMuted,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        )
                      : null,
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 14, top: 6),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: AppColor.expenseOnDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}