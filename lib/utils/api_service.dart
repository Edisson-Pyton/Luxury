import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _base = 'https://web-production-76013.up.railway.app';

  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
  };

  // ── Token ─────────────────────────────────────────────────
  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('access_token');
    return _cachedToken;
  }

  static Future<void> saveTokens(String access, String refresh) async {
    _cachedToken = access;
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
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Refresh token automático ──────────────────────────────
  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    final res = await http.post(
      Uri.parse('$_base/api/token/refresh/'),
      headers: _publicHeaders,
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _cachedToken = data['access'];
      await prefs.setString('access_token', data['access']);
      return true;
    }
    return false;
  }

  // POST autenticado con retry
  static Future<http.Response> _authenticatedPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    var headers = await _authHeaders();
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        headers = await _authHeaders();
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  // GET autenticado con retry
  static Future<http.Response> _authenticatedGet(String url) async {
    var headers = await _authHeaders();
    var response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        headers = await _authHeaders();
        response = await http.get(Uri.parse(url), headers: headers);
      }
    }
    return response;
  }

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
    final res = await _authenticatedGet('$_base/api/profile/');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<bool> saveProfile({
    required int age,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final res = await _authenticatedPost('$_base/api/profile/', {
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
    });
    if (res.statusCode == 200) {
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
    final res = await _authenticatedPost('$_base/api/rest-days/', {
      'rest_days': days,
    });
    return res.statusCode == 200;
  }

  // ── PROGRESO DE EJERCICIOS ────────────────────────────────
  static Future<List<int>> getWorkoutProgress(String goal) async {
    final res = await _authenticatedGet(
      '$_base/api/workout/progress/?goal=$goal',
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<int>.from(data['completed']);
    }
    return [];
  }

  static Future<bool> saveWorkoutProgress(int index, String goal) async {
    final res = await _authenticatedPost('$_base/api/workout/progress/', {
      'index': index,
      'goal': goal,
    });
    return res.statusCode == 200;
  }

  // ── RACHA FÍSICA ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getWorkoutStreak() async {
    final res = await _authenticatedGet('$_base/api/workout/streak/');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'streak': 0, 'worked_today': false, 'is_rest_day': false};
  }

  static Future<int> registerWorkoutDone() async {
    final res = await _authenticatedPost('$_base/api/workout/streak/', {});
    if (res.statusCode == 200) return jsonDecode(res.body)['streak'];
    return 0;
  }

  // ── RACHA MENTAL ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getMentalStreak() async {
    final res = await _authenticatedGet('$_base/api/mental/streak/');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'streak': 0, 'done_today': false, 'is_rest_day': false};
  }

  static Future<int> registerMentalDone() async {
    final res = await _authenticatedPost('$_base/api/mental/streak/', {});
    if (res.statusCode == 200) return jsonDecode(res.body)['streak'];
    return 0;
  }

  // ── PROGRESO MENTAL ───────────────────────────────────────
  static Future<List<int>> getMentalProgress() async {
    final res = await _authenticatedGet('$_base/api/mental/progress/');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<int>.from(data['completed']);
    }
    return [];
  }

  static Future<bool> saveMentalProgress(int index) async {
    final res = await _authenticatedPost('$_base/api/mental/progress/', {
      'index': index,
    });
    return res.statusCode == 200;
  }

  // ── ESTADO DE ÁNIMO ───────────────────────────────────────
  static Future<Map<String, dynamic>> getMood() async {
    final res = await _authenticatedGet('$_base/api/mental/mood/');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'today_mood': null, 'week_moods': {}};
  }

  static Future<Map<String, dynamic>> saveMood(int mood) async {
    final res = await _authenticatedPost('$_base/api/mental/mood/', {
      'mood': mood,
    });
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }

  // ── TEST PSICOLÓGICO ──────────────────────────────────────
  static Future<Map<String, dynamic>> getMentalTest() async {
    final res = await _authenticatedGet('$_base/api/mental/test/');
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {'done': false};
  }

  static Future<bool> saveMentalTest({
    required String profile,
    required int score,
    required List<int> answers,
  }) async {
    final res = await _authenticatedPost('$_base/api/mental/test/', {
      'profile': profile,
      'score': score,
      'answers': answers,
    });
    return res.statusCode == 200;
  }
}
