import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart'; 
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String getZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      return 'pisces';
    } else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else {
      return 'capricorn';
    }
  }

  Future<void> _login() async {
    final cedula = _cedulaController.text;
    final password = _passwordController.text;

    if (cedula.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingrese todos los campos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://adamix.net/minerd/def/iniciar_sesion.php'),
        body: {
          'cedula': cedula,
          'clave': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['exito']) {
          // Save user data for later use
          final userData = data['datos'];
          // Save token to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', userData['token']);
          await prefs.setString('nombre', userData['nombre']);
          await prefs.setString('apellido', userData['apellido']);
          await prefs.setString('fecha_nacimiento', userData['fecha_nacimiento']);

          DateTime birthDate = DateTime.parse(userData['fecha_nacimiento']);
          String zodiacSign = getZodiacSign(birthDate);
          await prefs.setString('zodiac_sign', zodiacSign);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage = data['mensaje'] ?? 'Credenciales incorrectas';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF0033A0), // Color principal de MINERD
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Image.asset(
                'assets/Login_logo.png', // Logo del MINERD
                height: 100,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula',
                labelStyle: TextStyle(color: Color(0xFF0033A0)), // Color principal de MINERD
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Color(0xFF0033A0)), // Color principal de MINERD
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                        ),
                        child: Text('Iniciar Sesión'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );
                        },
                        child: Text('¿No tienes una cuenta? Regístrate'),
                      ),
                    ],
                  ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
