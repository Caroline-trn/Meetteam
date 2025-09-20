import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meetteam/services/auth_service.dart';
import 'package:meetteam/theme/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      if (kDebugMode) {
        print("Tentative de connexion avec:");
        print("Email: ${_emailController.text}");
      }
      
      final result = await _authService.login(
        _emailController.text,
        _passwordController.text
      );

      if (kDebugMode) {
        print("Résultat de la connexion: $result");
      }

      setState(() => _isLoading = false);

      if (result['success']) {
        final userProfile = await _authService.getUserProfile();
        
        if (userProfile['success'] == true) {
          final userData = userProfile['data'];
          Navigator.pushReplacementNamed(
            // ignore: use_build_context_synchronously
            context,
            '/home',
            arguments: {
              'userName': userData['name'] ?? 'Utilisateur',
              'userEmail': userData['email'] ?? _emailController.text,
            },
          );
        } else {
          Navigator.pushReplacementNamed(
            // ignore: use_build_context_synchronously
            context,
            '/home',
            arguments: {
              'userName': _emailController.text.split('@')[0],
              'userEmail': _emailController.text,
            },
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: result['message'] ?? "Erreur de connexion",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Meetteam',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Se connecter'),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: const Text('Mot de passe oublié ?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}