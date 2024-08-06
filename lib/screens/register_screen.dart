import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; // Asegúrate de que esta ruta sea correcta

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _claveController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final cedula = _cedulaController.text;
    final nombre = _nombreController.text;
    final apellido = _apellidoController.text;
    final clave = _claveController.text;
    final correo = _correoController.text;
    final telefono = _telefonoController.text;
    final fecha = _fechaController.text;

    final url = Uri.parse('https://adamix.net/minerd/def/registro.php');
    final response = await http.post(url, body: {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'clave': clave,
      'correo': correo,
      'telefono': telefono,
      'fecha_nacimiento': fecha, 
    });

    if (response.statusCode == 200) {
      final responseBody = response.body;
      final success = responseBody.contains('"exito":true');
      if (success) {
        // Handle successful registration
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro exitoso')));
        // Navigate to login screen and replace the current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        // Handle registration failure
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en el registro: ${responseBody}')));
      }
    } else {
      // Handle server error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error del servidor: ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cedulaController,
                decoration: InputDecoration(labelText: 'Cédula'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese la cédula';
                  return null;
                },
              ),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese el nombre';
                  return null;
                },
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese el apellido';
                  return null;
                },
              ),
              TextFormField(
                controller: _claveController,
                decoration: InputDecoration(labelText: 'Clave'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese la clave';
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese el teléfono';
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(labelText: 'Fecha de nacimiento (aaaa-mm-dd)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                    return 'Por favor ingrese una fecha válida (aaaa-mm-dd)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
