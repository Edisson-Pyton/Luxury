import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/api_service.dart';

// ── Preguntas del test ────────────────────────────────────────
class _Question {
  final String text;
  final String category;
  const _Question(this.text, this.category);
}

const List<_Question> _questions = [
  _Question(
    'Me siento nervioso o con preocupaciones sin razón clara.',
    'ansiedad',
  ),
  _Question(
    'Tengo dificultades para dormir por pensamientos que no puedo controlar.',
    'ansiedad',
  ),
  _Question(
    'Siento que no soy suficiente o que los demás son mejores que yo.',
    'autoestima',
  ),
  _Question(
    'Me cuesta aceptar mis errores sin castigarme mentalmente.',
    'autoestima',
  ),
  _Question(
    'Siento tensión física (cabeza, cuello, hombros) por el estrés.',
    'estres',
  ),
  _Question(
    'Me siento sobrecargado por mis responsabilidades diarias.',
    'estres',
  ),
  _Question(
    'Me siento triste o sin motivación para hacer cosas que antes disfrutaba.',
    'animo',
  ),
  _Question(
    'Siento que mis emociones me controlan más de lo que quisiera.',
    'animo',
  ),
  _Question(
    'Evito situaciones sociales por miedo a ser juzgado.',
    'autoestima',
  ),
  _Question('Me cuesta concentrarme o tomar decisiones simples.', 'ansiedad'),
];

const List<String> _options = ['Nunca', 'A veces', 'Seguido', 'Siempre'];

Map<String, dynamic> _getProfile(int score) {
  if (score <= 8) {
    return {
      'title': 'Bienestar estable',
      'emoji': '😊',
      'color': const Color(0xFF43A047),
      'desc':
          'Tu estado emocional es saludable. Mantén tus hábitos positivos y sigue cuidando tu mente.',
      'tips': [
        'Practica la gratitud diaria escribiendo 3 cosas positivas.',
        'Mantén tu rutina de ejercicio para sostener tu bienestar.',
        'Reserva tiempo semanal para actividades que disfrutes.',
        'Cultiva tus relaciones sociales cercanas.',
        'Sigue durmiendo bien — es la base de la salud mental.',
      ],
    };
  } else if (score <= 16) {
    return {
      'title': 'Estrés moderado',
      'emoji': '😐',
      'color': const Color(0xFFFFA000),
      'desc':
          'Hay señales de estrés o preocupaciones que vale la pena atender antes de que escalen.',
      'tips': [
        'Incorpora pausas activas durante el día (5 min cada 2 horas).',
        'Practica la técnica de respiración 4-7-8 cuando sientas tensión.',
        'Identifica qué situaciones te generan más estrés y busca soluciones.',
        'Limita el tiempo en redes sociales a 30 min al día.',
        'Habla con alguien de confianza sobre lo que te preocupa.',
      ],
    };
  } else if (score <= 23) {
    return {
      'title': 'Ansiedad elevada',
      'emoji': '😔',
      'color': const Color(0xFFE53935),
      'desc':
          'Estás experimentando niveles significativos de ansiedad o baja autoestima. Es importante actuar.',
      'tips': [
        'Practica técnicas de respiración profunda al despertar y antes de dormir.',
        'Reduce las fuentes de estrés identificando lo que puedes controlar.',
        'Evita la cafeína y el alcohol — empeoran la ansiedad.',
        'Busca apoyo profesional si los síntomas persisten más de 2 semanas.',
        'Practica el autocuidado: baños relajantes, música tranquila, naturaleza.',
      ],
    };
  } else {
    return {
      'title': 'Atención prioritaria',
      'emoji': '💙',
      'color': const Color(0xFF6C63FF),
      'desc':
          'Tus respuestas indican un nivel alto de malestar emocional. No estás solo — hay formas de mejorar.',
      'tips': [
        'Considera hablar con un profesional de salud mental — es un acto de valentía.',
        'Empieza con un pequeño hábito diario: 5 minutos de respiración al despertar.',
        'No te aísles — busca conectar con alguien de confianza hoy.',
        'Recuerda que los sentimientos difíciles son temporales, no permanentes.',
        'El ejercicio físico suave (caminar 20 min) puede mejorar tu estado de ánimo.',
      ],
    };
  }
}

// ── Actividades mentales ──────────────────────────────────────
class _MentalActivity {
  final String name;
  final String duration;
  final String desc;
  final String howTo;
  final IconData icon;
  final Color color;
  const _MentalActivity({
    required this.name,
    required this.duration,
    required this.desc,
    required this.howTo,
    required this.icon,
    required this.color,
  });
}

const List<_MentalActivity> _allActivities = [
  _MentalActivity(
    name: 'Respiración 4-7-8',
    duration: '5 min',
    desc:
        'Técnica que activa el sistema nervioso parasimpático y reduce la ansiedad.',
    howTo:
        'Inhala 4 seg → Retén 7 seg → Exhala 8 seg. Repite 5 ciclos. Mano en el abdomen.',
    icon: Icons.air,
    color: Color(0xFF00897B),
  ),
  _MentalActivity(
    name: 'Meditación guiada',
    duration: '10 min',
    desc:
        'Silencio consciente para centrar la mente y soltar pensamientos que generan estrés.',
    howTo:
        'Siéntate cómodo, cierra los ojos y enfoca solo en tu respiración. Si divaga, vuelve sin juzgarte.',
    icon: Icons.self_improvement,
    color: Color(0xFF8E24AA),
  ),
  _MentalActivity(
    name: 'Journaling de gratitud',
    duration: '5 min',
    desc:
        'Escribir 3 cosas positivas del día entrena al cerebro a detectar lo bueno.',
    howTo:
        'Escribe 3 cosas específicas que agradeces hoy. Pueden ser pequeñas.',
    icon: Icons.book_outlined,
    color: Color(0xFFE91E63),
  ),
  _MentalActivity(
    name: 'Afirmaciones positivas',
    duration: '3 min',
    desc: 'Frases que reprograman el diálogo interno negativo.',
    howTo:
        'Frente al espejo di: "Soy capaz", "Me merezco bienestar", "Soy suficiente". 5 veces cada una.',
    icon: Icons.favorite_outline,
    color: Color(0xFFE53935),
  ),
  _MentalActivity(
    name: 'Diario emocional',
    duration: '10 min',
    desc:
        'Escribir lo que sientes sin filtros ayuda a procesar emociones difíciles.',
    howTo: 'Escribe sin censura: ¿Qué siento hoy? ¿Por qué? ¿Qué necesito?',
    icon: Icons.edit_outlined,
    color: Color(0xFF1E88E5),
  ),
  _MentalActivity(
    name: 'Respiración diafragmática',
    duration: '5 min',
    desc:
        'Respiración profunda que activa la respuesta de relajación del cuerpo.',
    howTo:
        'Mano en el abdomen. Inhala lento por la nariz sintiendo cómo se expande. Exhala lento.',
    icon: Icons.air_outlined,
    color: Color(0xFF00897B),
  ),
  _MentalActivity(
    name: 'Caminata consciente',
    duration: '15 min',
    desc: 'Caminar con atención plena reduce el cortisol significativamente.',
    howTo:
        'Sin teléfono. Observa colores, sonidos, texturas. Siente cada paso.',
    icon: Icons.directions_walk,
    color: Color(0xFF43A047),
  ),
  _MentalActivity(
    name: 'Postura de poder',
    duration: '2 min',
    desc:
        'Postura expansiva por 2 min que reduce el cortisol y aumenta la confianza.',
    howTo:
        'De pie, pies separados, manos en cadera. Pecho abierto, mentón arriba.',
    icon: Icons.accessibility_new,
    color: Color(0xFF6C63FF),
  ),
  _MentalActivity(
    name: 'Autocompasión',
    duration: '5 min',
    desc:
        'Hablarte con la misma amabilidad con la que le hablarías a un amigo.',
    howTo:
        'Mano en el corazón: "Es normal sentir esto. Estoy haciendo lo mejor que puedo."',
    icon: Icons.volunteer_activism,
    color: Color(0xFFE91E63),
  ),
  _MentalActivity(
    name: 'Estiramientos de cuello',
    duration: '5 min',
    desc: 'Libera la tensión física acumulada por el estrés.',
    howTo:
        'Inclina la cabeza a cada lado 20 seg, hacia adelante 20 seg. Lento.',
    icon: Icons.accessibility,
    color: Color(0xFFFFA000),
  ),
];

// ── Pantalla principal ────────────────────────────────────────
class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});
  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  // Test
  bool _testDone = false;
  Map<String, dynamic>? _profile;
  List<int> _answers = List.filled(10, -1);
  int _currentQ = 0;
  bool _showingTest = false;

  // Ánimo
  int? _todayMood = null;
  Map<String, int> _weekMoods = {};

  // Actividades + racha
  List<bool> _activitiesDone = [];
  int _mentalStreak = 0;
  bool _mentalDoneToday = false;
  bool _showMentalSummary = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    // Test
    final testData = await ApiService.getMentalTest();
    // Ánimo
    final moodData = await ApiService.getMood();
    // Racha mental
    final streakData = await ApiService.getMentalStreak();
    // Progreso actividades
    final mentalDone = await ApiService.getMentalProgress();

    if (!mounted) return;

    final completed = List.generate(
      _allActivities.length,
      (i) => mentalDone.contains(i),
    );
    final allDone = completed.isNotEmpty && completed.every((c) => c);

    // Convierte week_moods de Map<String,dynamic> a Map<String,int>
    final rawMoods = moodData['week_moods'] as Map<String, dynamic>? ?? {};
    final weekMoods = rawMoods.map((k, v) => MapEntry(k, (v as num).toInt()));

    setState(() {
      _testDone = testData['done'] ?? false;
      _profile = _testDone ? _getProfile(testData['score'] as int) : null;
      _todayMood = moodData['today_mood'] as int?;
      _weekMoods = weekMoods;
      _activitiesDone = completed;
      _mentalStreak = streakData['streak'] ?? 0;
      _mentalDoneToday = streakData['done_today'] ?? false;
      _showMentalSummary = allDone && (streakData['done_today'] ?? false);
      _loading = false;
    });
  }

  // ── Estado de ánimo con confirmación ─────────────────────
  Future<void> _confirmMood(int mood, String emoji, String label) async {
    if (_todayMood != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Ya registraste tu estado de ánimo hoy.')),
            ],
          ),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirmar estado de ánimo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              '¿Confirmas que hoy te sientes "$label"?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Solo puedes registrar un estado de ánimo por día.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.saveMood(mood);
      if (!mounted) return;
      if (result['status'] == 200) {
        final moodData = await ApiService.getMood();
        final rawMoods = moodData['week_moods'] as Map<String, dynamic>? ?? {};
        final weekMoods = rawMoods.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
        setState(() {
          _todayMood = mood;
          _weekMoods = weekMoods;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['data']['error'] ?? 'Error al guardar.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ── Finalizar test ────────────────────────────────────────
  Future<void> _finishTest() async {
    final score = _answers.fold(0, (a, b) => a + (b == -1 ? 0 : b));
    final profile = _getProfile(score);
    await ApiService.saveMentalTest(
      profile: profile['title'],
      score: score,
      answers: _answers,
    );
    if (!mounted) return;
    setState(() {
      _testDone = true;
      _profile = profile;
      _showingTest = false;
      _currentQ = 0;
    });
  }

  // ── Marcar actividad + racha ──────────────────────────────
  Future<void> _markActivity(int index) async {
    await ApiService.saveMentalProgress(index);
    setState(() => _activitiesDone[index] = true);

    if (_activitiesDone.every((d) => d)) {
      final streak = await ApiService.registerMentalDone();
      if (!mounted) return;
      setState(() {
        _mentalStreak = streak;
        _mentalDoneToday = true;
        _showMentalSummary = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Salud Mental'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🧘', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '$_mentalStreak días',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.psychology), text: 'Mi perfil'),
            Tab(icon: Icon(Icons.mood), text: 'Ánimo'),
            Tab(icon: Icon(Icons.spa), text: 'Rutina'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTestTab(), _buildMoodTab(), _buildActivitiesTab()],
      ),
    );
  }

  // ── TAB 1: TEST ───────────────────────────────────────────
  Widget _buildTestTab() {
    if (_showingTest) return _buildTestQuestions();
    if (_testDone && _profile != null) return _buildProfileResult();
    return _buildTestIntro();
  }

  Widget _buildTestIntro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text(
                  'Test de Bienestar Mental',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Responde 10 preguntas honestas sobre cómo te has sentido. '
                  'Tu perfil se guardará para darte consejos personalizados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showingTest = true),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Comenzar test',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    'Este test es orientativo y no reemplaza la evaluación de un profesional.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestQuestions() {
    final q = _questions[_currentQ];
    final progress = (_currentQ + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE91E63)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pregunta ${_currentQ + 1} de ${_questions.length}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              q.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ..._options.asMap().entries.map((e) {
            final selected = _answers[_currentQ] == e.key;
            return GestureDetector(
              onTap: () => setState(() => _answers[_currentQ] = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFE91E63).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE91E63)
                        : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFE91E63)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFE91E63)
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? const Color(0xFFE91E63)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _answers[_currentQ] == -1
                  ? null
                  : () async {
                      if (_currentQ < _questions.length - 1) {
                        setState(() => _currentQ++);
                      } else {
                        await _finishTest();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _currentQ < _questions.length - 1
                    ? 'Siguiente'
                    : 'Ver mi perfil',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileResult() {
    final color = _profile!['color'] as Color;
    final tips = _profile!['tips'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(
                  _profile!['emoji'] as String,
                  style: const TextStyle(fontSize: 52),
                ),
                const SizedBox(height: 12),
                Text(
                  _profile!['title'] as String,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _profile!['desc'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '💡 Consejos personalizados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ...tips.asMap().entries.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️ ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    'Este resultado es orientativo. Si necesitas apoyo profesional, no dudes en buscarlo.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── TAB 2: ÁNIMO ─────────────────────────────────────────
  Widget _buildMoodTab() {
    final moods = [
      {
        'emoji': '😄',
        'label': 'Excelente',
        'value': 4,
        'color': const Color(0xFF43A047),
      },
      {
        'emoji': '🙂',
        'label': 'Bien',
        'value': 3,
        'color': const Color(0xFF00897B),
      },
      {
        'emoji': '😐',
        'label': 'Regular',
        'value': 2,
        'color': const Color(0xFFFFA000),
      },
      {
        'emoji': '😔',
        'label': 'Mal',
        'value': 1,
        'color': const Color(0xFFE53935),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Aviso si ya registró
                if (_todayMood != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✅ Ya registraste tu estado de ánimo hoy',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: moods.map((m) {
                    final val = m['value'] as int;
                    final selected = _todayMood == val;
                    final locked = _todayMood != null;
                    return GestureDetector(
                      onTap: () => _confirmMood(
                        val,
                        m['emoji'] as String,
                        m['label'] as String,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              m['emoji'] as String,
                              style: TextStyle(
                                fontSize: locked && !selected ? 24 : 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['label'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Tu semana',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          _weekMoods.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'Aún no hay datos.\nRegistra tu estado de ánimo cada día.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (i) {
                          final day = DateTime.now().subtract(
                            Duration(days: 6 - i),
                          );
                          final key =
                              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                          final mood = _weekMoods[key];
                          final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                          final dayLabel = days[day.weekday - 1];
                          final colors = [
                            Colors.grey.shade200,
                            const Color(0xFFE53935),
                            const Color(0xFFFFA000),
                            const Color(0xFF00897B),
                            const Color(0xFF43A047),
                          ];
                          final barH = mood != null ? (mood * 20.0) : 8.0;
                          return Column(
                            children: [
                              Container(
                                width: 28,
                                height: barH,
                                decoration: BoxDecoration(
                                  color: mood != null
                                      ? colors[mood]
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dayLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: moods.reversed
                            .map(
                              (m) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m['emoji'] as String,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    m['label'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── TAB 3: RUTINA MENTAL ──────────────────────────────────
  Widget _buildActivitiesTab() {
    if (_showMentalSummary) return _buildMentalSummary();

    final doneCount = _activitiesDone.where((d) => d).length;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Header con racha
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rutina mental de hoy 🧘',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _allActivities.isEmpty
                      ? 0
                      : doneCount / _allActivities.length,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$doneCount / ${_allActivities.length} completadas',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Racha mental
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧘', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      _mentalStreak == 0
                          ? 'Sin racha aún'
                          : '$_mentalStreak día${_mentalStreak == 1 ? '' : 's'} de racha',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_mentalDoneToday) ...[
                      const SizedBox(width: 8),
                      const Text('✅', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_mentalDoneToday) ...[
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
                Text('😴', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ya completaste tu rutina mental hoy. ¡Excelente trabajo!',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        const Text(
          'Toca una actividad para ver cómo hacerla',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        ..._allActivities.asMap().entries.map((e) {
          final done = _activitiesDone[e.key];
          final act = e.value;
          return GestureDetector(
            onTap: () => _showActivityDetail(e.key, act),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: done ? act.color.withOpacity(0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: done
                      ? act.color.withOpacity(0.4)
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: act.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(act.icon, color: act.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: done ? Colors.grey : Colors.black87,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          act.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: done ? Colors.grey.shade400 : act.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  done
                      ? Icon(Icons.check_circle, color: act.color, size: 24)
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── Resumen mental ────────────────────────────────────────
  Widget _buildMentalSummary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '¡Rutina mental completada!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Completaste ${_allActivities.length} actividades mentales',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Racha
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🧘', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '$_mentalStreak día${_mentalStreak == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'de racha mental',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: const Text(
                '🌟 Cuidar tu mente cada día es el acto de amor más importante que puedes hacer por ti mismo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(int index, _MentalActivity act) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityDetailModal(
        activity: act,
        isDone: _activitiesDone[index],
        onDone: () {
          Navigator.pop(context);
          _markActivity(index);
        },
      ),
    );
  }
}

// ── Modal de detalle ──────────────────────────────────────────
class _ActivityDetailModal extends StatefulWidget {
  final _MentalActivity activity;
  final bool isDone;
  final VoidCallback onDone;
  const _ActivityDetailModal({
    required this.activity,
    required this.isDone,
    required this.onDone,
  });
  @override
  State<_ActivityDetailModal> createState() => _ActivityDetailModalState();
}

class _ActivityDetailModalState extends State<_ActivityDetailModal> {
  bool _timerActive = false;
  int _secondsLeft = 0;
  Timer? _timer;

  void _startTimer(int seconds) {
    setState(() {
      _timerActive = true;
      _secondsLeft = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _timerActive = false);
        widget.onDone();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    setState(() {
      _timerActive = false;
      _secondsLeft = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  int _durationSeconds(String dur) {
    if (dur.contains('15')) return 15 * 60;
    if (dur.contains('10')) return 10 * 60;
    if (dur.contains('5')) return 5 * 60;
    if (dur.contains('3')) return 3 * 60;
    if (dur.contains('2')) return 2 * 60;
    return 5 * 60;
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;
    final sec = _durationSeconds(act.duration);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: act.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(act.icon, color: act.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        act.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        act.duration,
                        style: TextStyle(
                          color: act.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              act.desc,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '📋 Cómo hacerlo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: act.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: act.color.withOpacity(0.2)),
              ),
              child: Text(
                act.howTo,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            const SizedBox(height: 28),
            if (widget.isDone)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      '¡Actividad completada hoy!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (_timerActive)
              Column(
                children: [
                  Text(
                    _fmt(_secondsLeft),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _secondsLeft <= 10 ? Colors.red : act.color,
                    ),
                  ),
                  const Text(
                    'Sigue así...',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _cancelTimer,
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startTimer(sec),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    'Iniciar (${act.duration})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: act.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
