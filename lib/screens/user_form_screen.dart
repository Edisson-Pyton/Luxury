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
  String? _ageError;
  String? _weightError;
  String? _heightError;
  double? _imc;
  bool _saved = false;

  // Días de descanso
  List<int> _restDays = [];
  int _daysToChange = 0;
  bool _restDaysSet = false;

  final List<String> _goals = [
    'Perder peso',
    'Ganar músculo',
    'Mejorar resistencia',
    'Reducir estrés',
    'Mejorar autoestima',
  ];

  // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom
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
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final data = await LocalStorage.getFormData();
    final restDays = await LocalStorage.getRestDays();
    final daysToChg = await LocalStorage.daysUntilCanChangeRestDays();

    if (!mounted) return;
    setState(() {
      if (data != null) {
        _ageCtrl.text = data['age'].toString();
        _weightCtrl.text = data['weight'].toString();
        _heightCtrl.text = data['height'].toString();
        _goal = data['goal'];
        _imc = _calcIMC(data['weight'], data['height']);
        _saved = true;
      }
      _restDays = restDays;
      _daysToChange = daysToChg;
      _restDaysSet = restDays.isNotEmpty;
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

  Future<void> _handleGoalChange(String newGoal) async {
    if (newGoal == _goal) return;
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
      if (confirm != true) return;
      await LocalStorage.clearTodayProgress();
    }
    setState(() => _goal = newGoal);
  }

  // ── Manejo de días de descanso ────────────────────────────
  void _toggleRestDay(int day) {
    if (_daysToChange > 0 && _restDaysSet) return; // bloqueado

    setState(() {
      if (_restDays.contains(day)) {
        _restDays.remove(day);
      } else {
        if (_restDays.length < 2) {
          _restDays.add(day);
        } else {
          // Ya tiene 2, reemplaza el más antiguo
          _restDays.removeAt(0);
          _restDays.add(day);
        }
      }
    });
  }

  Future<void> _saveRestDays() async {
    if (_restDays.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona exactamente 2 días de descanso.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    await LocalStorage.saveRestDays(_restDays);
    final daysToChg = await LocalStorage.daysUntilCanChangeRestDays();
    if (!mounted) return;
    setState(() {
      _daysToChange = daysToChg;
      _restDaysSet = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Días de descanso guardados.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

            // IMC
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

            // ── Días de descanso ──────────────────────────
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.hotel, color: Color(0xFF6C63FF), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Días de descanso',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_daysToChange > 0 && _restDaysSet)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      '🔒 $_daysToChange días',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            Text(
              _daysToChange > 0 && _restDaysSet
                  ? 'Podrás cambiar tus días de descanso en $_daysToChange días.'
                  : 'Elige exactamente 2 días de descanso. Solo podrás cambiarlos cada 30 días.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 14),

            // Selector de días
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final selected = _restDays.contains(i);
                final blocked = _daysToChange > 0 && _restDaysSet;
                return GestureDetector(
                  onTap: blocked ? null : () => _toggleRestDay(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6C63FF)
                          : blocked
                          ? Colors.grey.shade100
                          : Colors.grey.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayNames[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : blocked
                              ? Colors.grey.shade400
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Botón guardar días de descanso
            if (!(_daysToChange > 0 && _restDaysSet))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saveRestDays,
                  icon: const Icon(
                    Icons.save_outlined,
                    color: Color(0xFF6C63FF),
                  ),
                  label: const Text(
                    'Guardar días de descanso',
                    style: TextStyle(color: Color(0xFF6C63FF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6C63FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Info de días actuales si ya están guardados
            if (_restDaysSet && _restDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('😴', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tus días de descanso: ${_restDays.map((d) => _dayNames[d]).join(' y ')}. '
                        'La racha no se rompe esos días.',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
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
