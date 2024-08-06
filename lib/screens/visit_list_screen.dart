import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class VisitListScreen extends StatefulWidget {
  @override
  _VisitListScreenState createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  List<dynamic> _visits = [];
  bool _isLoading = false;
  String? _errorMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _errorMessage = 'Token no encontrado. Inicia sesión de nuevo.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://adamix.net/minerd/def/situaciones.php'),
        body: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['exito']) {
          setState(() {
            _visits = data['datos'];
          });
        } else {
          setState(() {
            _errorMessage = data['mensaje'] ?? 'Error al obtener visitas';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener visitas';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAllVisits() async {
    setState(() {
      _visits.clear();
    });
  }

  Future<void> _fetchVisitDetails(String situacionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'Token no encontrado. Inicia sesión de nuevo.';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://adamix.net/minerd/def/situacion.php?token=$token&situacion_id=$situacionId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exito']) {
        _showVisitDetails(data['datos']);
      } else {
        setState(() {
          _errorMessage = data['mensaje'] ?? 'Error al obtener detalles de la visita';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Error en la conexión';
      });
    }
  }

  void _showVisitDetails(Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la Visita'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${visit['id']}'),
              Text('Cédula Director: ${visit['cedula_director']}'),
              Text('Código Centro: ${visit['codigo_centro']}'),
              Text('Motivo: ${visit['motivo']}'),
              Text('Comentario: ${visit['comentario']}'),
              Text('Latitud: ${visit['latitud']}'),
              Text('Longitud: ${visit['longitud']}'),
              Text('Fecha: ${visit['fecha']}'),
              Text('Hora: ${visit['hora']}'),
              SizedBox(height: 10),
              if (visit['foto_evidencia'].isNotEmpty)
                Image.network(
                  visit['foto_evidencia'],
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              SizedBox(height: 10),
              if (visit['nota_voz'].isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _audioPlayer.setUrl(visit['nota_voz']);
                      await _audioPlayer.play();
                    } catch (e) {
                      print('Error al reproducir el audio: $e');
                    }
                  },
                  child: Text('Reproducir Audio'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFFFF0000),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Visitas'),
        backgroundColor: Color(0xFF0033A0), // Azul
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAllVisits,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: _visits.length,
                  itemBuilder: (context, index) {
                    final visit = _visits[index];
                    return Card(
                      color: Colors.white, // Fondo blanco para el card
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 5, // Sombra sutil
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          visit['motivo'] ?? 'Sin motivo',
                          style: TextStyle(color: Color(0xFF0033A0), fontWeight: FontWeight.bold), // Azul
                        ),
                        subtitle: Text(
                          'Fecha: ${visit['fecha'] ?? 'Sin fecha'}',
                          style: TextStyle(color: Color(0xFF0033A0)), // Azul
                        ),
                        onTap: () => _fetchVisitDetails(visit['id']),
                      ),
                    );
                  },
                ),
    );
  }
}
