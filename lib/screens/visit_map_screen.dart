import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VisitMapScreen extends StatefulWidget {
  @override
  _VisitMapScreenState createState() => _VisitMapScreenState();
}

class _VisitMapScreenState extends State<VisitMapScreen> {
  List<dynamic> _situations = [];
  bool _isLoading = false;
  String? _errorMessage;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchSituations();
  }

  Future<void> _fetchSituations() async {
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
            _situations = data['datos'];
          });
        } else {
          setState(() {
            _errorMessage = data['mensaje'] ?? 'Error al obtener situaciones';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener situaciones';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMap(Map<String, dynamic> situation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(situation: situation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Situaciones'),
        backgroundColor: Color(0xFF0033A0), // Azul
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchSituations,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: _situations.length,
                  itemBuilder: (context, index) {
                    final situation = _situations[index];
                    return Card(
                      color: Colors.white, // Fondo blanco para el card
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 5, // Sombra sutil
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          situation['motivo'] ?? 'Sin motivo',
                          style: TextStyle(color: Color(0xFF0033A0), fontWeight: FontWeight.bold), // Azul
                        ),
                        subtitle: Text(
                          'Fecha: ${situation['fecha'] ?? 'Sin fecha'}',
                          style: TextStyle(color: Color(0xFF0033A0)), // Azul
                        ),
                        onTap: () => _navigateToMap(situation),
                      ),
                    );
                  },
                ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final Map<String, dynamic> situation;

  MapScreen({required this.situation});

  @override
  Widget build(BuildContext context) {
    double latitud = double.parse(situation['latitud']);
    double longitud = double.parse(situation['longitud']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicación'),
        backgroundColor: Color(0xFF0033A0), // Azul
      ),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          center: LatLng(latitud, longitud),
          zoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latitud, longitud),
                builder: (ctx) => IconButton(
                  icon: Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 40.0,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Información del Marcador'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Código Centro: ${situation['codigo_centro']}'),
                            Text('Motivo: ${situation['motivo']}'),
                            Text('Fecha: ${situation['fecha']}'),
                            Text('Hora: ${situation['hora']}'),
                            Text('Latitud: $latitud'),
                            Text('Longitud: $longitud'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
