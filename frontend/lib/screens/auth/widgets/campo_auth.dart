import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Campo de texto de las pantallas de cuenta, con el estilo oscuro de la app.
class CampoAuth extends StatefulWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final bool esContrasena;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  const CampoAuth({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.esContrasena = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<CampoAuth> createState() => _CampoAuthState();
}

class _CampoAuthState extends State<CampoAuth> {
  bool _oculta = true;

  OutlineInputBorder _borde(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.esContrasena && _oculta,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      textAlignVertical: TextAlignVertical.center,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        labelStyle: const TextStyle(color: AppColors.textoTenue),
        floatingLabelStyle: const TextStyle(color: AppColors.primario),
        prefixIcon: Icon(widget.icono, color: AppColors.primario, size: 20),
        suffixIcon: widget.esContrasena
            ? IconButton(
                tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
                icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textoTenue, size: 20),
                onPressed: () => setState(() => _oculta = !_oculta),
              )
            : null,
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: _borde(AppColors.borde),
        focusedBorder: _borde(AppColors.primario),
        errorBorder: _borde(Colors.redAccent),
        focusedErrorBorder: _borde(Colors.redAccent),
      ),
    );
  }
}
