import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  bool _formDone = false;
  int _streak = 0;
  int _mentalStreak = 0;
  bool _isRestDay = false;
  List<int> _restDays = [];
  bool _loading = true;

  final List<String> _dayNames = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Usuario';

    // Lee del servidor, no de caché local
    final profile = await ApiService.getProfile();
    final workoutData = await ApiService.getWorkoutStreak();
    final mentalData = await ApiService.getMentalStreak();

    if (!mounted) return;

    // formCompleted viene del servidor, no de caché
    final formDone = profile?['form_completed'] ?? false;

    // Actualiza también la caché local
    await prefs.setBool('formCompleted', formDone);

    setState(() {
      _name = profile?['name'] ?? name;
      _formDone = formDone;
      _streak = workoutData['streak'] ?? 0;
      _mentalStreak = mentalData['streak'] ?? 0;
      _isRestDay = workoutData['is_rest_day'] ?? false;
      _restDays = profile != null
          ? List<int>.from(profile['rest_days'] ?? [])
          : [];
      _loading = false;
    });
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFF6C63FF)),
            SizedBox(width: 10),
            Text('¿Cerrar sesión?'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres salir?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sí, salir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Primero completa tus datos personales.')),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _sectionCard({
    required String emoji,
    required Color emojiColor,
    required String title,
    required String desc,
    required String? badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required bool locked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: locked ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: locked
                    ? Colors.grey.shade100
                    : emojiColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: locked
                    ? const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                        size: 24,
                      )
                    : Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: locked ? Colors.grey : Colors.black87,
                        ),
                      ),
                      if (badge != null && !locked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              color: badgeTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    locked ? 'Completa tus datos personales primero' : desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: locked
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              locked ? Icons.lock_outline : Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, Color iconColor, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakBadge(String text, {Color? bg}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg ?? Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmLogout();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text(
            'Luxury',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenW > 600 ? screenW * 0.1 : 18,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Banner ────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido de nuevo',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hola, $_name 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Tu camino hacia el bienestar integral empieza aquí.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (_isRestDay)
                                      _streakBadge(
                                        '😴 Hoy es día de descanso',
                                        bg: Colors.white.withOpacity(0.25),
                                      )
                                    else ...[
                                      _streakBadge(
                                        '🔥 $_streak días racha física',
                                      ),
                                      _streakBadge(
                                        '🧘 $_mentalStreak días racha mental',
                                      ),
                                    ],
                                  ],
                                ),
                                if (_restDays.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '😴 Descanso: ${_restDays.map((d) => _dayNames[d]).join(' y ')}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _isRestDay ? '😴' : '🌟',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Aviso día de descanso
                    if (_isRestDay) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Text('😴', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Hoy es tu día de descanso. Tu racha está protegida.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Aviso formulario
                    if (!_formDone) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Para desbloquear todas las funciones, primero completa tus datos personales.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text(
                      '¿Qué quieres hacer hoy?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _sectionCard(
                      emoji: '👤',
                      emojiColor: const Color(0xFF6C63FF),
                      title: 'Mis datos personales',
                      desc:
                          'Registra tu peso, altura y objetivo. Calculamos tu IMC y adaptamos todo a ti.',
                      badge: null,
                      badgeColor: Colors.transparent,
                      badgeTextColor: Colors.transparent,
                      locked: false,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/form',
                      ).then((_) => _loadData()),
                    ),

                    _sectionCard(
                      emoji: '💪',
                      emojiColor: const Color(0xFF43A047),
                      title: 'Rutinas de ejercicio',
                      desc:
                          'Ejercicios personalizados según tu objetivo. Temporizador, series y racha diaria.',
                      badge: 'Sin equipamiento',
                      badgeColor: const Color(0xFFEAF3DE),
                      badgeTextColor: const Color(0xFF3B6D11),
                      locked: !_formDone,
                      onTap: () => _formDone
                          ? Navigator.pushNamed(context, '/workout')
                          : _showLockedMessage(),
                    ),

                    _sectionCard(
                      emoji: '🧠',
                      emojiColor: const Color(0xFFE91E63),
                      title: 'Salud mental',
                      desc:
                          'Test psicológico, estado de ánimo diario y actividades de bienestar mental.',
                      badge: 'Test + rutina',
                      badgeColor: const Color(0xFFFBEAF0),
                      badgeTextColor: const Color(0xFF993556),
                      locked: !_formDone,
                      onTap: () => _formDone
                          ? Navigator.pushNamed(context, '/mental')
                          : _showLockedMessage(),
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 32),

                    // ── Quiénes somos ─────────────────────
                    const Text(
                      '¿Qué es Luxury?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _infoCard(
                      Icons.favorite_rounded,
                      const Color(0xFFE91E63),
                      'Nuestra misión',
                      'Conectar el bienestar físico y mental en una sola plataforma. Sabemos que la insatisfacción corporal afecta directamente la salud emocional — Luxury aborda ambas.',
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10, right: 5),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.insights_rounded,
                                  color: Color(0xFF6C63FF),
                                  size: 22,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Basado en datos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rutinas adaptadas a tu cuerpo y objetivos reales.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10, left: 5),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  color: Color(0xFF43A047),
                                  size: 22,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Apoyo integral',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ejercicio físico y salud mental juntos, no por separado.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    _infoCard(
                      Icons.groups_rounded,
                      const Color(0xFF6C63FF),
                      '¿Por qué lo hacemos?',
                      'La insatisfacción corporal es uno de los factores más silenciosos en la aparición de ansiedad y depresión. Luxury nació para cambiar eso.',
                    ),

                    _infoCard(
                      Icons.auto_awesome_rounded,
                      const Color(0xFFFFA000),
                      'Nuestra promesa',
                      'No somos un app de dietas ni de motivación vacía. Somos un sistema que te acompaña con datos, rutinas reales y apoyo emocional.',
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
