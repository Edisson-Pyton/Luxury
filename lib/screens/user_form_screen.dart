import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/local_storage.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});
  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String _goal = 'Perder peso';
  // ignore: unused_field
  String _previousGoal = 'Perder peso';
  String? _ageError;
  String? _weightError;
  String? _heightError;
  double? _imc;
  bool _saved = false;

  final List<String> _goals = [
    'Perder peso',
    'Ganar músculo',
    'Mejorar resistencia',
    'Reducir estrés',
    'Mejorar autoestima',
  ];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final data = await LocalStorage.getFormData();
    if (data == null) return;
    setState(() {
      _ageCtrl.text = data['age'].toString();
      _weightCtrl.text = data['weight'].toString();
      _heightCtrl.text = data['height'].toString();
      _goal = data['goal'];
      _previousGoal = data['goal'];
      _imc = _calcIMC(data['weight'], data['height']);
      _saved = true;
    });
  }

  double? _calcIMC(double weight, double height) {
    if (weight <= 0 || height <= 0) return null;
    final hm = height / 100;
    return weight / (hm * hm);
  }

  Map<String, dynamic> _imcInfo(double imc) {
    if (imc < 18.5) return {'label': 'Bajo peso', 'color': Colors.blue};
    if (imc < 25.0) return {'label': 'Peso normal', 'color': Colors.green};
    if (imc < 30.0) return {'label': 'Sobrepeso', 'color': Colors.orange};
    return {'label': 'Obesidad', 'color': Colors.red};
  }

  String? _validateAge(String val) {
    if (val.isEmpty) return 'Ingresa tu edad.';
    final n = int.tryParse(val);
    if (n == null || n < 10 || n > 100) return 'Edad entre 10 y 100 años.';
    return null;
  }

  String? _validateWeight(String val) {
    if (val.isEmpty) return 'Ingresa tu peso.';
    final n = double.tryParse(val);
    if (n == null || n < 20 || n > 300) return 'Peso entre 20 y 300 kg.';
    return null;
  }

  String? _validateHeight(String val) {
    if (val.isEmpty) return 'Ingresa tu altura.';
    final n = double.tryParse(val);
    if (n == null || n < 100 || n > 250) return 'Altura entre 100 y 250 cm.';
    return null;
  }

  // Maneja el cambio de objetivo con aviso si hay progreso del día
  Future<void> _handleGoalChange(String newGoal) async {
    if (newGoal == _goal) return;

    // Si el objetivo anterior ya tenía progreso hoy, muestra aviso
    final progress = await LocalStorage.getTodayProgress(_goal);
    if (progress.isNotEmpty && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('¿Cambiar objetivo?'),
            ],
          ),
          content: const Text(
            'Tienes ejercicios completados hoy con tu objetivo actual. '
            'Si cambias el objetivo, el progreso de hoy se reiniciará.',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sí, cambiar'),
            ),
          ],
        ),
      );

      if (confirm != true) return; // canceló, no cambia

      // Limpia el progreso del día
      await LocalStorage.clearTodayProgress();
    }

    setState(() => _goal = newGoal);
  }

  Future<void> _save() async {
    setState(() {
      _ageError = _validateAge(_ageCtrl.text);
      _weightError = _validateWeight(_weightCtrl.text);
      _heightError = _validateHeight(_heightCtrl.text);
    });
    if (_ageError != null || _weightError != null || _heightError != null)
      return;

    final age = int.parse(_ageCtrl.text);
    final weight = double.parse(_weightCtrl.text);
    final height = double.parse(_heightCtrl.text);

    await LocalStorage.saveFormData(
      age: age,
      weight: weight,
      height: height,
      goal: _goal,
    );

    setState(() {
      _imc = _calcIMC(weight, height);
      _saved = true;
      _previousGoal = _goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis datos personales'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuéntanos sobre ti',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Usaremos estos datos para personalizar tus rutinas y recomendaciones.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            InputField(
              label: 'Edad',
              controller: _ageCtrl,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              errorText: _ageError,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            InputField(
              label: 'Peso (kg)',
              controller: _weightCtrl,
              icon: Icons.monitor_weight_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              errorText: _weightError,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            const SizedBox(height: 16),

            InputField(
              label: 'Altura (cm)',
              controller: _heightCtrl,
              icon: Icons.height,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              errorText: _heightError,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Mi objetivo principal:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Chips de objetivo con aviso al cambiar
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _goals
                  .map(
                    (g) => GestureDetector(
                      onTap: () => _handleGoalChange(g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _goal == g
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _goal == g
                                ? const Color(0xFF6C63FF)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            color: _goal == g ? Colors.white : Colors.black87,
                            fontWeight: _goal == g
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            // Tarjeta IMC
            if (_imc != null) ...[
              const SizedBox(height: 28),
              _IMCCard(imc: _imc!, info: _imcInfo(_imc!)),
            ],

            const SizedBox(height: 28),
            CustomButton(
              text: _saved ? 'Actualizar datos' : 'Guardar datos',
              onPressed: _save,
            ),

            if (_saved) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Datos guardados! Ya puedes acceder a tus rutinas.',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta IMC ───────────────────────────────────────────────
class _IMCCard extends StatelessWidget {
  final double imc;
  final Map<String, dynamic> info;
  const _IMCCard({required this.imc, required this.info});

  @override
  Widget build(BuildContext context) {
    final color = info['color'] as Color;
    final label = info['label'] as String;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: color),
              const SizedBox(width: 8),
              const Text(
                'Tu IMC',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                imc.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (imc.clamp(10, 40) - 10) / 30,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('10', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('18.5', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('25', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('30', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('40+', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _tip(imc),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _tip(double imc) {
    if (imc < 18.5)
      return 'Tu peso está por debajo del rango saludable. Te recomendamos rutinas de ganancia de masa y consultar un nutricionista.';
    if (imc < 25.0)
      return '¡Excelente! Tu peso está en el rango saludable. Mantén tus hábitos con rutinas de mantenimiento.';
    if (imc < 30.0)
      return 'Estás en sobrepeso. Las rutinas de cardio y una alimentación balanceada te ayudarán a mejorar.';
    return 'Tu IMC indica obesidad. Te recomendamos comenzar con rutinas suaves y buscar apoyo profesional.';
  }
}
