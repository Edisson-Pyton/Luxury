import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<void> saveUser(
    String email,
    String password,
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('name', name);
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'Usuario';
  }

  // ── Formulario ────────────────────────────────────────────
  static Future<void> saveFormData({
    required int age,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('age', age);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setString('goal', goal);
    await prefs.setBool('formCompleted', true);
  }

  static Future<bool> isFormCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('formCompleted') ?? false;
  }

  static Future<Map<String, dynamic>?> getFormData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('formCompleted') ?? false)) return null;
    return {
      'age': prefs.getInt('age') ?? 0,
      'weight': prefs.getDouble('weight') ?? 0.0,
      'height': prefs.getDouble('height') ?? 0.0,
      'goal': prefs.getString('goal') ?? '',
    };
  }

  // ── Días de descanso ──────────────────────────────────────
  // 0=Lun, 1=Mar, 2=Mié, 3=Jue, 4=Vie, 5=Sáb, 6=Dom
  static Future<void> saveRestDays(List<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('restDays', days.map((d) => '$d').toList());
    await prefs.setString('restDaysSetDate', DateTime.now().toIso8601String());
  }

  static Future<List<int>> getRestDays() async {
    final prefs = await SharedPreferences.getInstance();
    final days = prefs.getStringList('restDays') ?? [];
    return days.map((d) => int.parse(d)).toList();
  }

  // Días que faltan para poder cambiarlos (bloqueo 30 días)
  static Future<int> daysUntilCanChangeRestDays() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString('restDaysSetDate');
    if (dateStr == null) return 0;
    final setDate = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(setDate).inDays;
    final remaining = 30 - diff;
    return remaining > 0 ? remaining : 0;
  }

  // Si hoy es día de descanso
  static Future<bool> isTodayRestDay() async {
    final days = await getRestDays();
    // weekday: 1=Lun...7=Dom → convertimos a 0=Lun...6=Dom
    final todayIndex = DateTime.now().weekday - 1;
    return days.contains(todayIndex);
  }

  // ── Progreso físico del día ───────────────────────────────
  static Future<void> saveExerciseProgress(int index, String goal) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _progressKey(goal);
    final done = prefs.getStringList(key) ?? [];
    if (!done.contains('$index')) {
      done.add('$index');
      await prefs.setStringList(key, done);
    }
  }

  static Future<List<int>> getTodayProgress(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getStringList(_progressKey(goal)) ?? [];
    return done.map((e) => int.parse(e)).toList();
  }

  static Future<void> cleanOldProgress(String currentGoal) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = _progressKey(currentGoal);
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith('progress_') && key != currentKey) {
        await prefs.remove(key);
      }
    }
  }

  static Future<void> clearTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith('progress_$today')) {
        await prefs.remove(key);
      }
    }
  }

  // ── Racha física (respeta días de descanso) ───────────────
  static Future<void> registerWorkoutDone() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStr = prefs.getString('lastWorkoutDate');
    final streak = prefs.getInt('streak') ?? 0;

    if (lastStr != null) {
      final last = DateTime.parse(lastStr);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) return;

      if (diff == 1) {
        await prefs.setInt('streak', streak + 1);
      } else {
        // Verifica si los días intermedios eran todos de descanso
        final restDays = await getRestDays();
        bool allRest = true;
        for (int i = 1; i < diff; i++) {
          final checkDay = lastDay.add(Duration(days: i));
          if (!restDays.contains(checkDay.weekday - 1)) {
            allRest = false;
            break;
          }
        }
        await prefs.setInt('streak', allRest ? streak + 1 : 1);
      }
    } else {
      await prefs.setInt('streak', 1);
    }
    await prefs.setString('lastWorkoutDate', today.toIso8601String());
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak') ?? 0;
  }

  static Future<bool> workedOutToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString('lastWorkoutDate');
    if (lastStr == null) return false;
    final last = DateTime.parse(lastStr);
    final now = DateTime.now();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  // ── Racha mental (respeta días de descanso) ───────────────
  static Future<void> registerMentalDone() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStr = prefs.getString('lastMentalDate');
    final streak = prefs.getInt('mentalStreak') ?? 0;

    if (lastStr != null) {
      final last = DateTime.parse(lastStr);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) return;

      if (diff == 1) {
        await prefs.setInt('mentalStreak', streak + 1);
      } else {
        final restDays = await getRestDays();
        bool allRest = true;
        for (int i = 1; i < diff; i++) {
          final checkDay = lastDay.add(Duration(days: i));
          if (!restDays.contains(checkDay.weekday - 1)) {
            allRest = false;
            break;
          }
        }
        await prefs.setInt('mentalStreak', allRest ? streak + 1 : 1);
      }
    } else {
      await prefs.setInt('mentalStreak', 1);
    }
    await prefs.setString('lastMentalDate', today.toIso8601String());
  }

  static Future<int> getMentalStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('mentalStreak') ?? 0;
  }

  static Future<bool> mentalDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString('lastMentalDate');
    if (lastStr == null) return false;
    final last = DateTime.parse(lastStr);
    final now = DateTime.now();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  // ── Test psicológico ──────────────────────────────────────
  static Future<void> saveMentalTestResult({
    required String profile,
    required int score,
    required List<int> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mental_profile', profile);
    await prefs.setInt('mental_score', score);
    await prefs.setStringList(
      'mental_answers',
      answers.map((e) => '$e').toList(),
    );
    await prefs.setBool('mental_test_done', true);
  }

  static Future<bool> isMentalTestDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('mental_test_done') ?? false;
  }

  static Future<Map<String, dynamic>?> getMentalTestResult() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('mental_test_done') ?? false)) return null;
    return {
      'profile': prefs.getString('mental_profile') ?? '',
      'score': prefs.getInt('mental_score') ?? 0,
      'answers': (prefs.getStringList('mental_answers') ?? [])
          .map((e) => int.parse(e))
          .toList(),
    };
  }

  // ── Estado de ánimo ───────────────────────────────────────
  static Future<void> saveMood(int mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mood_${_todayKey()}', mood);
  }

  static Future<int?> getTodayMood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('mood_${_todayKey()}');
  }

  static Future<Map<String, int>> getWeekMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final val = prefs.getInt('mood_$key');
      if (val != null) result[key] = val;
    }
    return result;
  }

  // ── Progreso mental del día ───────────────────────────────
  static Future<void> saveMentalActivityProgress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'mental_progress_${_todayKey()}';
    final done = prefs.getStringList(key) ?? [];
    if (!done.contains('$index')) {
      done.add('$index');
      await prefs.setStringList(key, done);
    }
  }

  static Future<List<int>> getTodayMentalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getStringList('mental_progress_${_todayKey()}') ?? [];
    return done.map((e) => int.parse(e)).toList();
  }

  // ── Helpers ───────────────────────────────────────────────
  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _progressKey(String goal) {
    return 'progress_${_todayKey()}_${goal.replaceAll(' ', '_')}';
  }
}
