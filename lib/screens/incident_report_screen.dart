import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:minerd/models/incident.dart';
import 'package:minerd/services/db_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IncidentReportScreen extends StatefulWidget {
  @override
  _IncidentReportScreenState createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = '';
  String _centroEducativo = '';
  String _regional = '';
  String _distrito = '';
  DateTime _fecha = DateTime.now();
  String _descripcion = '';
  File? _foto;
  File? _audio;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  Future<void> _startRecording() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = '${appDocDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
      if (_audioPath != null) {
        _audio = File(_audioPath!);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final incidencia = Incidencia(
        titulo: _titulo,
        centroEducativo: _centroEducativo,
        regional: _regional,
        distrito: _distrito,
        fecha: _fecha,
        descripcion: _descripcion,
        fotoPath: _foto?.path ?? '',
        audioPath: _audio?.path ?? '',
      );
      await DBService.insertIncidencia(incidencia);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Incidencia'),
        backgroundColor: Color(0xFF0033A0), // Azul
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese un título';
                    return null;
                  },
                  onSaved: (value) => _titulo = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Centro Educativo',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese el centro educativo';
                    return null;
                  },
                  onSaved: (value) => _centroEducativo = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Regional',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la regional';
                    return null;
                  },
                  onSaved: (value) => _regional = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Distrito',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese el distrito';
                    return null;
                  },
                  onSaved: (value) => _distrito = value!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), 
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), 
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese una descripción';
                    return null;
                  },
                  onSaved: (value) => _descripcion = value!,
                ),
                SizedBox(height: 20),
                _foto != null
                    ? Image.file(_foto!)
                    : Text('No se ha tomado una foto.'),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 197, 1, 1),
                  ),
                ),
                SizedBox(height: 20),
                _isRecording
                    ? ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: Icon(Icons.stop),
                        label: Text('Detener Grabación'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color(0xFFFF0000), 
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _startRecording,
                        icon: Icon(Icons.mic),
                        label: Text('Grabar Nota de Voz'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color(0xFFFF0000), 
                        ),
                      ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Registrar Incidencia'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF0033A0), // Blanco
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
