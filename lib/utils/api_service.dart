import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔗 URL base de tu backend en Railway
  static const String _base = 'https://web-production-76013.up.railway.app';

  // ── Token ─────────────────────────────────────────────────
  // Token en memoria (más confiable en web)
  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('access_token');
    return _cachedToken;
  }

  static Future<void> saveTokens(String access, String refresh) async {
    _cachedToken = access; // guarda en memoria
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<void> clearTokens() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    print('TOKEN ENVIADO: $token'); // para debug
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
  };

  // ── REGISTRO ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/register/'),
      headers: _publicHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201) {
      await saveTokens(data['access'], data['refresh']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', data['name']);
      await prefs.setString('email', data['email']);
      await prefs.setBool('isLoggedIn', true);
    }
    return {'status': res.statusCode, 'data': data};
  }

  // ── LOGIN ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/login/'),
      headers: _publicHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', data['name']);
      await prefs.setString('email', data['email']);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('formCompleted', data['form_completed'] ?? false);
    }
    return {'status': res.statusCode, 'data': data};
  }

  // ── LOGOUT ────────────────────────────────────────────────
  static Future<void> logout() async {
    await clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  // ── PERFIL ────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await http.get(
      Uri.parse('$_base/api/profile/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<bool> saveProfile({
    required int age,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/profile/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'age': age,
        'weight': weight,
        'height': height,
        'goal': goal,
      }),
    );
    if (res.statusCode == 200) {
      // Guarda también local para acceso rápido
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('age', age);
      await prefs.setDouble('weight', weight);
      await prefs.setDouble('height', height);
      await prefs.setString('goal', goal);
      await prefs.setBool('formCompleted', true);
    }
    return res.statusCode == 200;
  }

  // ── DÍAS DE DESCANSO ──────────────────────────────────────
  static Future<bool> saveRestDays(List<int> days) async {
    final res = await http.post(
      Uri.parse('$_base/api/rest-days/'),
      headers: await _authHeaders(),
      body: jsonEncode({'rest_days': days}),
    );
    return res.statusCode == 200;
  }

  // ── PROGRESO DE EJERCICIOS ────────────────────────────────
  static Future<List<int>> getWorkoutProgress(String goal) async {
    final res = await http.get(
      Uri.parse('$_base/api/workout/progress/?goal=$goal'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<int>.from(data['completed']);
    }
    return [];
  }

  static Future<bool> saveWorkoutProgress(int index, String goal) async {
    final res = await http.post(
      Uri.parse('$_base/api/workout/progress/'),
      headers: await _authHeaders(),
      body: jsonEncode({'index': index, 'goal': goal}),
    );
    return res.statusCode == 200;
  }

  // ── RACHA FÍSICA ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getWorkoutStreak() async {
    final res = await http.get(
      Uri.parse('$_base/api/workout/streak/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'streak': 0, 'worked_today': false, 'is_rest_day': false};
  }

  static Future<int> registerWorkoutDone() async {
    final res = await http.post(
      Uri.parse('$_base/api/workout/streak/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['streak'];
    return 0;
  }

  // ── RACHA MENTAL ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getMentalStreak() async {
    final res = await http.get(
      Uri.parse('$_base/api/mental/streak/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'streak': 0, 'done_today': false, 'is_rest_day': false};
  }

  static Future<int> registerMentalDone() async {
    final res = await http.post(
      Uri.parse('$_base/api/mental/streak/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body)['streak'];
    return 0;
  }

  // ── PROGRESO MENTAL ───────────────────────────────────────
  static Future<List<int>> getMentalProgress() async {
    final res = await http.get(
      Uri.parse('$_base/api/mental/progress/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<int>.from(data['completed']);
    }
    return [];
  }

  static Future<bool> saveMentalProgress(int index) async {
    final res = await http.post(
      Uri.parse('$_base/api/mental/progress/'),
      headers: await _authHeaders(),
      body: jsonEncode({'index': index}),
    );
    return res.statusCode == 200;
  }

  // ── ESTADO DE ÁNIMO ───────────────────────────────────────
  static Future<Map<String, dynamic>> getMood() async {
    final res = await http.get(
      Uri.parse('$_base/api/mental/mood/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'today_mood': null, 'week_moods': {}};
  }

  static Future<Map<String, dynamic>> saveMood(int mood) async {
    final res = await http.post(
      Uri.parse('$_base/api/mental/mood/'),
      headers: await _authHeaders(),
      body: jsonEncode({'mood': mood}),
    );
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }

  // ── TEST PSICOLÓGICO ──────────────────────────────────────
  static Future<Map<String, dynamic>> getMentalTest() async {
    final res = await http.get(
      Uri.parse('$_base/api/mental/test/'),
      headers: await _authHeaders(),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'done': false};
  }

  static Future<bool> saveMentalTest({
    required String profile,
    required int score,
    required List<int> answers,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/mental/test/'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'profile': profile,
        'score': score,
        'answers': answers,
      }),
    );
    return res.statusCode == 200;
  }
}
