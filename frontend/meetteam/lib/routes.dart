import 'package:flutter/material.dart';
import 'package:meetteam/screens/login_screen.dart';
import 'package:meetteam/screens/register_screen.dart'; // Vérifiez cet import
import 'package:meetteam/screens/forgot_password_screen.dart';
import 'package:meetteam/screens/home_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen()); // Ligne problématique
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen(userName: '', userEmail: ''));
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}