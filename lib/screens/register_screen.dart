import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

const String _kRegisterBgUrl =
    'https://wallpapers.com/images/hd/yoga-background-vhje1idvdj7qm33z.jpg';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passError;
  String? _confirmError;
  String _generalError = '';
  bool _loading = false;

  String? _validateName(String val) {
    if (val.isEmpty) return 'El nombre es obligatorio.';
    if (val.trim().length < 8) return 'Mínimo 8 caracteres.';
    return null;
  }

  String? _validateEmail(String val) {
    if (val.isEmpty) return 'El correo es obligatorio.';
    final regex = RegExp(r'^[\w\.\+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(val.trim()))
      return 'Ingresa un correo válido (ej: nombre@gmail.com).';
    return null;
  }

  String? _validatePhone(String val) {
    if (val.isEmpty) return 'El teléfono es obligatorio.';
    if (val.length < 7) return 'Mínimo 7 dígitos.';
    if (val.length > 15) return 'Máximo 15 dígitos.';
    return null;
  }

  String? _validatePassword(String val) {
    if (val.isEmpty) return 'La contraseña es obligatoria.';
    if (val.length < 6) return 'Mínimo 6 caracteres.';
    if (!val.contains(RegExp(r'[A-Z]')))
      return 'Debe contener al menos una mayúscula.';
    return null;
  }

  String? _validateConfirm(String val) {
    if (val.isEmpty) return 'Confirma tu contraseña.';
    if (val != _passCtrl.text) return 'Las contraseñas no coinciden.';
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _nameError = _validateName(_nameCtrl.text);
      _emailError = _validateEmail(_emailCtrl.text);
      _phoneError = _validatePhone(_phoneCtrl.text);
      _passError = _validatePassword(_passCtrl.text);
      _confirmError = _validateConfirm(_confirmCtrl.text);
      _generalError = '';
    });

    if (_nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _passError != null ||
        _confirmError != null)
      return;

    setState(() => _loading = true);

    final result = await ApiService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['status'] == 201) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final data = result['data'];
      setState(() => _generalError = data['error'] ?? 'Error al registrarse.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo
          Image.network(
            _kRegisterBgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3E3799), Color(0xFF6C63FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Capa oscura
          Container(color: Colors.black.withOpacity(0.50)),

          // Contenido
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom + 16),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width > 600 ? size.width * 0.2 : 28,
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.04),

                    // Ícono
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.favorite_outline,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Crea tu cuenta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Empieza tu camino hacia el bienestar',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Tarjeta glass
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              InputField(
                                label: 'Nombre completo',
                                controller: _nameCtrl,
                                icon: Icons.person_outline,
                                errorText: _nameError,
                                glassMode: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              InputField(
                                label: 'Correo electrónico',
                                controller: _emailCtrl,
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                errorText: _emailError,
                                glassMode: true,
                              ),
                              const SizedBox(height: 14),

                              InputField(
                                label: 'Teléfono',
                                controller: _phoneCtrl,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                errorText: _phoneError,
                                glassMode: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                              ),
                              const SizedBox(height: 14),

                              InputField(
                                label: 'Contraseña',
                                controller: _passCtrl,
                                icon: Icons.lock_outline,
                                obscure: true,
                                errorText: _passError,
                                glassMode: true,
                              ),
                              const SizedBox(height: 8),
                              _PasswordHints(
                                password: _passCtrl.text,
                                onChanged: () => setState(() {}),
                              ),
                              const SizedBox(height: 14),

                              InputField(
                                label: 'Confirmar contraseña',
                                controller: _confirmCtrl,
                                icon: Icons.lock_person_outlined,
                                obscure: true,
                                errorText: _confirmError,
                                glassMode: true,
                              ),
                              const SizedBox(height: 8),
                              _MatchHint(
                                pass: _passCtrl.text,
                                confirm: _confirmCtrl.text,
                                onChanged: () => setState(() {}),
                              ),

                              if (_generalError.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _generalError,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),

                              // Botón con loading
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Registrarme',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Ya tengo cuenta · Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Requisitos de contraseña ──────────────────────────────────
class _PasswordHints extends StatelessWidget {
  final String password;
  final VoidCallback onChanged;
  const _PasswordHints({required this.password, required this.onChanged});

  Widget _hint(String text, bool met) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: met ? Colors.greenAccent : Colors.white60,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.greenAccent : Colors.white60,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _hint('Mínimo 6 caracteres', password.length >= 6),
      _hint('Al menos una mayúscula', password.contains(RegExp(r'[A-Z]'))),
    ],
  );
}

// ── Coincidencia de contraseñas ───────────────────────────────
class _MatchHint extends StatelessWidget {
  final String pass;
  final String confirm;
  final VoidCallback onChanged;
  const _MatchHint({
    required this.pass,
    required this.confirm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (confirm.isEmpty) return const SizedBox();
    final match = pass == confirm;
    return Row(
      children: [
        Icon(
          match ? Icons.check_circle : Icons.cancel_outlined,
          size: 14,
          color: match ? Colors.greenAccent : Colors.redAccent,
        ),
        const SizedBox(width: 6),
        Text(
          match ? 'Las contraseñas coinciden' : 'Las contraseñas no coinciden',
          style: TextStyle(
            fontSize: 12,
            color: match ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}
