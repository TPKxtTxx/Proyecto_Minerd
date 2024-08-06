import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';

class HoroscopeScreen extends StatefulWidget {
  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String _horoscope = '';
  String _zodiacSign = '';

  @override
  void initState() {
    super.initState();
    _loadZodiacSign();
  }

  Future<void> _loadZodiacSign() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? zodiacSign = prefs.getString('zodiac_sign');
    if (zodiacSign != null) {
      setState(() {
        _zodiacSign = zodiacSign;
      });
      _fetchHoroscope(zodiacSign);
    }
  }

  Future<void> _fetchHoroscope(String zodiacSign) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final today = dateFormat.format(DateTime.now());
    final url = 'https://horoscope-app-api.vercel.app/api/v1/get-horoscope/daily?sign=$zodiacSign&day=$today';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final horoscopeData = data['data']['horoscope_data'];

        if (horoscopeData != null) {
          final translatedHoroscope = await _translateText(horoscopeData, 'es');
          setState(() {
            _horoscope = translatedHoroscope;
          });
        } else {
          setState(() {
            _horoscope = 'No hay datos disponibles';
          });
        }
      } else {
        setState(() {
          _horoscope = 'Error al cargar el horóscopo';
        });
      }
    } catch (e) {
      setState(() {
        _horoscope = 'Error al cargar el horóscopo: $e';
      });
    }
  }

  Future<String> _translateText(String text, String targetLanguage) async {
    final translator = GoogleTranslator();

    try {
      final translation = await translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      return 'Error al traducir el texto: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horóscopo Diario'),
        backgroundColor: Color(0xFF0033A0), // Azul
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signo del Zodiaco: $_zodiacSign',
              style: TextStyle(color: Color(0xFF0033A0), fontSize: 20), // Azul
            ),
            SizedBox(height: 20),
            Text(
              _horoscope,
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
            ),
          ],
        ),
      ),
    );
  }
}
