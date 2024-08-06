import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? nombre;
  String? apellido;
  String? token;
  String? zodiacSign;
  String? photoPath = 'assets/technician_photo.jpg'; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('nombre');
      apellido = prefs.getString('apellido');
      token = prefs.getString('token');
      zodiacSign = prefs.getString('zodiac_sign');
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
            
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(photoPath!), 
            ),
            SizedBox(height: 20),
            Text(
              nombre != null && apellido != null ? '$nombre $apellido' : 'Cargando...',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF0033A0), // Color principal del MINERD
              ),
            ),
            Text(
              'Número de Placa: ${token ?? 'Cargando...'}',
              style: TextStyle(color: Color(0xFF0033A0)), // Color principal del MINERD
            ),
            SizedBox(height: 20),
            Text(
              'Signo Zodiacal: ${zodiacSign ?? 'Cargando...'}',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF0033A0), // Color principal del MINERD
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Reflexión o cita sobre seguridad:',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF0033A0), // Color principal del MINERD
              ),
            ),
            Text(
              '"La seguridad es nuestra prioridad. Trabajamos con compromiso y dedicación para proteger a nuestra comunidad."',
              style: TextStyle(color: Colors.black87), // Color del texto
            ),
          ],
        ),
      ),
    );
  }
}
