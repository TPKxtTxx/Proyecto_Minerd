import 'package:flutter/material.dart';
import 'package:minerd/models/director.dart';
import 'package:minerd/services/api_service.dart';

class DirectorSearchScreen extends StatefulWidget {
  @override
  _DirectorSearchScreenState createState() => _DirectorSearchScreenState();
}

class _DirectorSearchScreenState extends State<DirectorSearchScreen> {
  final _cedulaController = TextEditingController();
  Director? _director;
  bool _isLoading = false;

  Future<void> _searchDirector() async {
    setState(() {
      _isLoading = true;
    });

    final cedula = _cedulaController.text;
    final director = await ApiService.searchDirectorByCedula(cedula);

    setState(() {
      _isLoading = false;
      _director = director;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF0033A0), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Image.asset(
                'assets/Minerd_logo.png',
                height: 80,
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula del Director',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xFF0033A0)), 
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _searchDirector,
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text('Buscar'),
              ),
            ),
            SizedBox(height: 20),
            _director == null
                ? Text(
                    'Ingrese la cédula para buscar al director.',
                    style: TextStyle(color: Color(0xFF0033A0)),
                  )
                : _buildDirectorDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectorDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_director!.photoUrl.isNotEmpty)
          Image.network(
            _director!.photoUrl,
            height: 100,
            width: 100,
          ),
        SizedBox(height: 10),
        Text(
          'Nombre: ${_director!.nombre} ${_director!.apellido}',
          style: TextStyle(fontSize: 18, color: Color(0xFF0033A0)), 
        ),
        Text(
          'Fecha de Nacimiento: ${_director!.fechaNacimiento}',
          style: TextStyle(color: Color(0xFF0033A0)), 
        ),
        Text(
          'Dirección: ${_director!.direccion}',
          style: TextStyle(color: Color(0xFF0033A0)), 
        ),
        Text(
          'Teléfono: ${_director!.telefono}',
          style: TextStyle(color: Color(0xFF0033A0)), 
        ),
      ],
    );
  }
}
