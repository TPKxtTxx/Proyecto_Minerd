import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class VisitRegisterScreen extends StatefulWidget {
  @override
  _VisitRegisterScreenState createState() => _VisitRegisterScreenState();
}

class _VisitRegisterScreenState extends State<VisitRegisterScreen> {
  final TextEditingController _cedulaDirectorController = TextEditingController();
  final TextEditingController _codigoCentroController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  File? _fotoEvidencia;
  File? _notaVoz;
  bool _isLoading = false;
  bool _isFetchingCentro = false;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();
  FlutterSoundRecorder? _recorder;
  String? _audioPath;
  bool _isRecording = false;

  late String _token;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
    _retrieveToken();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.camera.request();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  void _startRecording() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = '${appDocDirectory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: path);
    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  void _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _retrieveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _fotoEvidencia = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchCentroData() async {
    final codigoCentro = _codigoCentroController.text;
    if (codigoCentro.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingrese el código del centro';
      });
      return;
    }

    setState(() {
      _isFetchingCentro = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://adamix.net/minerd/minerd/centros.php?regional=*'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool centroFound = false;

        for (var centro in data['datos']) {
          if (centro['codigo'] == codigoCentro) {
            final coordenadas = centro['coordenadas']?.split(',');
            setState(() {
              _latitudController.text = coordenadas?[0] ?? '';
              _longitudController.text = coordenadas?[1] ?? '';
            });
            centroFound = true;
            break;
          }
        }

        if (!centroFound) {
          setState(() {
            _errorMessage = 'Código del centro no encontrado';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener datos del centro';
      });
    } finally {
      setState(() {
        _isFetchingCentro = false;
      });
    }
  }

  Future<String?> _encodeFileToBase64(File? file) async {
    if (file == null) return '';
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error al codificar el archivo: $e');
      return '';
    }
  }

  Future<void> _registerVisit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final cedulaDirector = _cedulaDirectorController.text;
    final codigoCentro = _codigoCentroController.text;
    final motivo = _motivoController.text;
    final comentario = _comentarioController.text;
    final latitud = _latitudController.text;
    final longitud = _longitudController.text;
    final fecha = _fechaController.text;
    final hora = _horaController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fotoBase64 = await _encodeFileToBase64(_fotoEvidencia);
      final notaVozBase64 = await _encodeFileToBase64(_notaVoz);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://adamix.net/minerd/minerd/registrar_visita.php'),
      );

      request.fields['cedula_director'] = cedulaDirector;
      request.fields['codigo_centro'] = codigoCentro;
      request.fields['motivo'] = motivo;
      request.fields['comentario'] = comentario;
      request.fields['latitud'] = latitud;
      request.fields['longitud'] = longitud;
      request.fields['fecha'] = fecha;
      request.fields['hora'] = hora;
      request.fields['token'] = _token;
      request.fields['foto_evidencia'] = fotoBase64 ?? ' ';
      request.fields['nota_voz'] = notaVozBase64 ?? ' ';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        if (data['exito']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage = data['mensaje'] ?? 'Error al registrar visita';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar visita: $e';
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
        title: Text('Registrar Visita'),
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
                  controller: _cedulaDirectorController,
                  decoration: InputDecoration(
                    labelText: 'Cédula del Director',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la cédula del director';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codigoCentroController,
                        decoration: InputDecoration(
                          labelText: 'Código del Centro',
                          labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Por favor ingrese el código del centro';
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _fetchCentroData();
                          }
                        },
                      ),
                    ),
                    _isFetchingCentro
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _latitudController,
                  decoration: InputDecoration(
                    labelText: 'Latitud',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la latitud';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _longitudController,
                  decoration: InputDecoration(
                    labelText: 'Longitud',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la longitud';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _motivoController,
                  decoration: InputDecoration(
                    labelText: 'Motivo',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese el motivo';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _comentarioController,
                  decoration: InputDecoration(
                    labelText: 'Comentario',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese un comentario';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha (aaaa/mm/dd)',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), // Azul
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)), // Azul
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la fecha';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _horaController,
                  decoration: InputDecoration(
                    labelText: 'Hora (HH:MM)',
                    labelStyle: TextStyle(color: Color(0xFF0033A0)), 
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0033A0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Por favor ingrese la hora';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.camera),
                  label: Text('Tomar Foto Evidencia'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFFFF0000), 
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
                  onPressed: _registerVisit,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Registrar Visita'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF0033A0), 
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
