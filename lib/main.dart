import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtaempanada/db/firebase_options.dart';
import 'listproducts_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // Simulamos que la información del token se obtiene de alguna forma
      future: _getTokenFromSharedPreferences(),
      builder: (context, tokenSnapshot) {
        if (tokenSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          final String? token = tokenSnapshot.data;

          if (token != null && token.isNotEmpty) {
            return ProductsListScreen();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }

  Future<String?> _getTokenFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      // Manejo de la excepción, como imprimir un mensaje de error
      print('Error al obtener el token de SharedPreferences: $e');
      return null;
    }
  }
}
