import 'package:flutter/material.dart';
import 'package:vtaempanada/listproducts_screen.dart';

import 'db/firebase_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final String username = _usernameController.text;
        final String password = _passwordController.text;

        await FirestoreService().createUser(username, password);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProductsListScreen()),
        );
        print('User registered: $username');
      } catch (e) {
        _showAlertDialog('Error', 'Error durante el registro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Cuenta')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/register.png',
            height: 50, // Ruta de tu imagen de fondo
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        'images/images.png',
                        height: 130,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration:
                            InputDecoration(labelText: 'Nombre de Usuario'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un nombre de usuario';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese una contraseña';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _registerUser,
                        child: Text('Registrar Cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
