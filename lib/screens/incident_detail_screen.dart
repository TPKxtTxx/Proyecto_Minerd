import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minerd/models/incident.dart';
import 'package:just_audio/just_audio.dart';


class IncidentDetailScreen extends StatefulWidget {
  final Incidencia incidencia;

  IncidentDetailScreen({required this.incidencia});

  @override
  _IncidentDetailScreenState createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (widget.incidencia.audioPath.isNotEmpty) {
      try {
        await _audioPlayer.setFilePath(widget.incidencia.audioPath);
        _audioPlayer.play();
      } catch (e) {
        // Manejo de errores, por ejemplo, mostrar un mensaje al usuario
        print("Error al reproducir el audio: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incidencia.titulo),
        backgroundColor: Color(0xFF0033A0), // Azul
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Centro Educativo: ${widget.incidencia.centroEducativo}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0033A0), // Azul
              ),
            ),
            Text(
              'Regional: ${widget.incidencia.regional}',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Negro
            ),
            Text(
              'Distrito: ${widget.incidencia.distrito}',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Negro
            ),
            Text(
              'Fecha: ${widget.incidencia.fecha.toLocal()}',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Negro
            ),
            SizedBox(height: 20),
            Text(
              'Descripción:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0), // Negro
              ),
            ),
            Text(widget.incidencia.descripcion),
            SizedBox(height: 20),
            if (widget.incidencia.fotoPath.isNotEmpty)
              Image.file(File(widget.incidencia.fotoPath)),
            if (widget.incidencia.audioPath.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _playAudio,
                icon: Icon(Icons.play_arrow),
                label: Text('Reproducir Audio'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFFFF0000), // Rojo
                ),
              ),
          ],
        ),
      ),
    );
  }
}
