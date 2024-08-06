import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchoolSearchScreen extends StatefulWidget {
  @override
  _SchoolSearchScreenState createState() => _SchoolSearchScreenState();
}

class _SchoolSearchScreenState extends State<SchoolSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _schoolDetails;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchSchoolDetails(String schoolCode) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://adamix.net/minerd/minerd/centros.php?regional=*')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['exito'] == true) {
          final school = (data['datos'] as List)
              .firstWhere((item) => item['codigo'] == schoolCode, orElse: () => null);

          setState(() {
            if (school != null) {
              _schoolDetails = school;
            } else {
              _schoolDetails = null;
              _errorMessage = 'Escuela no encontrada';
            }
          });
        } else {
          setState(() {
            _errorMessage = data['mensaje'] ?? 'Error al obtener detalles de la escuela';
            _schoolDetails = null;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
          _schoolDetails = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener detalles de la escuela';
        _schoolDetails = null;
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
        title: Text('Buscar Escuela'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Imagen centrada en la parte superior
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 20),
              child: Image.asset(
                'assets/Minerd_logo.png',
                height: 100, 
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Código de la Escuela'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _fetchSchoolDetails(_controller.text);
              },
              child: Text('Buscar'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _errorMessage != null
                    ? Text(_errorMessage!)
                    : _schoolDetails != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nombre: ${_schoolDetails!['nombre'] ?? 'No disponible'}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Dirección: ${_schoolDetails!['d_dmunicipal'] ?? 'No disponible'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Código: ${_schoolDetails!['codigo'] ?? 'No disponible'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Coordenadas: ${_schoolDetails!['coordenadas'] ?? 'No disponible'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Text('No se encontraron detalles de la escuela'),
          ],
        ),
      ),
    );
  }
}
