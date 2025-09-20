import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meetteam/constante.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final _logger = _AuthLogger();

  // Méthode pour obtenir l'URL de base
  static String getBaseUrl() {
    if (kIsWeb) {
      return '$API_BASE_URL/api';
    } else {
      return '$API_BASE_URL/api';
    }
  }

  // NOUVELLE MÉTHODE REGISTER
  Future<Map<String, dynamic>> register(String name, String email, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      _logger.debug('Register Status Code: ${response.statusCode}');
      _logger.debug('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true, 
          'message': data['message'] ?? 'Inscription réussie',
          'data': data
        };
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Erreur lors de l\'inscription';
        
        if (errorData['errors'] != null) {
          // Gestion des erreurs de validation Laravel
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0] ?? errorMessage;
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
        
        return {
          'success': false, 
          'message': errorMessage
        };
      }
    } catch (e) {
      _logger.error('Register error: $e');
      return {
        'success': false, 
        'message': 'Erreur de connexion: $e'
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      _logger.debug('Status Code: ${response.statusCode}');
      _logger.debug('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToken(data['token']);
        return {
          'success': true, 
          'message': 'Connexion réussie',
          'data': data
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false, 
          'message': errorData['message'] ?? 'Email ou mot de passe incorrect'
        };
      }
    } catch (e) {
      _logger.error('Login error: $e');
      return {
        'success': false, 
        'message': 'Erreur de connexion: $e'
      };
    }
  }

  Future<Map<String, dynamic>> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      _logger.debug('Reset Password Status: ${response.statusCode}');
      _logger.debug('Reset Password Response: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Code envoyé par email'};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false, 
          'message': errorData['message'] ?? 'Erreur lors de l\'envoi du code'
        };
      }
    } catch (e) {
      _logger.error('Reset password error: $e');
      return {
        'success': false, 
        'message': 'Erreur de connexion: $e'
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
  try {
    final token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token non disponible'};
    }

    final response = await http.get(
      Uri.parse('$API_BASE_URL/api/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {'success': true, 'data': responseData['data'] ?? responseData};
    } else {
      return {
        'success': false, 
        'message': 'Erreur ${response.statusCode}',
        'statusCode': response.statusCode
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Erreur: $e'};
  }
}
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      _logger.debug('Token sauvegardé: $token');
    } catch (e) {
      _logger.error('Erreur sauvegarde token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      _logger.error('Erreur lecture token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _logger.info('Déconnexion réussie');
    } catch (e) {
      _logger.error('Erreur déconnexion: $e');
    }
  }
}

// Classe de logging personnalisée
class _AuthLogger {
  void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] AuthService: $message');
    }
  }

  void info(String message) {
    if (kDebugMode) {
      print('[INFO] AuthService: $message');
    }
  }

  void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] AuthService: $message');
    }
  }

  void error(String message) {
    // Les erreurs sont toujours loggées, même en production
    if (kDebugMode) {
      print('[ERROR] AuthService: $message');
    }
  }
}