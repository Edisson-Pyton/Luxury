import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final IconData icon;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final bool glassMode; // true en login/registro, false en otras pantallas

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.inputFormatters,
    this.glassMode = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final isGlass = widget.glassMode;

    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(
        color: isGlass ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: isGlass ? Colors.white70 : const Color(0xFF6C63FF),
          fontSize: 14,
        ),
        errorText: widget.errorText,
        errorStyle: TextStyle(
          color: isGlass ? Colors.redAccent.shade100 : Colors.red,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: isGlass ? Colors.white70 : const Color(0xFF6C63FF),
          size: 20,
        ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: isGlass ? Colors.white60 : Colors.grey,
                  size: 20,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,

        // Fondo
        filled: true,
        fillColor: isGlass
            ? Colors.white.withOpacity(0.12)
            : Colors.grey.shade50,

        // Bordes
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isGlass ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isGlass ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isGlass ? Colors.white70 : const Color(0xFF6C63FF),
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isGlass ? Colors.redAccent.shade100 : Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isGlass ? Colors.redAccent.shade100 : Colors.red,
            width: 1.8,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
