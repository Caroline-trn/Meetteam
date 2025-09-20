import 'package:flutter/material.dart';
import 'package:meetteam/screens/login_screen.dart';
import 'package:meetteam/screens/home_screen.dart';
import 'package:meetteam/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:meetteam/screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
//import 'screens/verify_code_screen.dart';
//import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Meetteam',
        theme: ThemeData(
          
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
          future: AuthService().getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.hasData ? const HomeScreen(userName: '', userEmail: '') : const LoginScreen();
            }
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(userName: '', userEmail: ''),
          '/register': (context) => const RegisterScreen(), // Ajoutez cette route
          '/forgot-password': (context) => const ForgotPasswordScreen(), // Ajoutez cette route
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}