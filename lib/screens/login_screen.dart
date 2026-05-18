import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/local_storage.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

const String _kLoginBgUrl =
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=1200&q=80';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _emailError;
  String? _passError;
  String _generalError = '';

  String? _validateEmail(String val) {
    if (val.isEmpty) return 'Ingresa tu correo.';
    final regex = RegExp(r'^[\w\.\+\-]+@[a-zA-Z\d\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(val.trim())) return 'Formato de correo inválido.';
    return null;
  }

  String? _validatePassword(String val) {
    if (val.isEmpty) return 'Ingresa tu contraseña.';
    return null;
  }

  Future<void> _login() async {
    setState(() {
      _emailError = _validateEmail(_emailCtrl.text);
      _passError = _validatePassword(_passCtrl.text);
      _generalError = '';
    });
    if (_emailError != null || _passError != null) return;

    final saved = await LocalStorage.getUser();
    if (saved == null) {
      setState(
        () => _generalError = 'No hay cuenta registrada. Regístrate primero.',
      );
      return;
    }
    if (_emailCtrl.text.trim() == saved['email'] &&
        _passCtrl.text == saved['password']) {
      await LocalStorage.saveUser(
        saved['email']!,
        saved['password']!,
        await LocalStorage.getName(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _generalError = 'Correo o contraseña incorrectos.');
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
          // ── Imagen de fondo ──────────────────────────
          Image.network(
            _kLoginBgUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3E3799)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Capa oscura ──────────────────────────────
          Container(color: Colors.black.withOpacity(0.45)),

          // ── Contenido ────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width > 600 ? size.width * 0.2 : 28,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.08),

                      // Ícono
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Bienvenido a Luxury',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Inicia sesión para continuar tu camino',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // ── Tarjeta glass ────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.all(24),
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
                                  label: 'Correo electrónico',
                                  controller: _emailCtrl,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  errorText: _emailError,
                                  glassMode: true,
                                ),
                                const SizedBox(height: 16),

                                InputField(
                                  label: 'Contraseña',
                                  controller: _passCtrl,
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                  errorText: _passError,
                                  glassMode: true,
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

                                const SizedBox(height: 22),
                                CustomButton(
                                  text: 'Iniciar sesión',
                                  onPressed: _login,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
