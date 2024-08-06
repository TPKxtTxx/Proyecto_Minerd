import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _cityName = "Santo Domingo";
  String _weather = "";
  String _temperature = "";
  Color _backgroundColor = Colors.white;
  String _backgroundImage = "";

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final apiKey = 'c0de2842d170bd2e8f80f11f8fabbc6a';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$_cityName&appid=$apiKey&units=metric&lang=es';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = data['weather'][0]['description'];
          _temperature = data['main']['temp'].toString();
          _updateBackground(data['weather'][0]['main']);
        });
      } else {
        setState(() {
          _weather = "Error al obtener el clima";
          _temperature = "";
          _backgroundColor = Colors.grey;
        });
      }
    } catch (e) {
      setState(() {
        _weather = "Error al conectar con el servidor";
        _temperature = "";
        _backgroundColor = Colors.grey;
      });
    }
  }

  void _updateBackground(String weatherMain) {
    switch (weatherMain) {
      case 'Clouds':
        _backgroundColor = Colors.grey;
        _backgroundImage = 'assets/cloudy.png';
        break;
      case 'Rain':
        _backgroundColor = Colors.blueGrey;
        _backgroundImage = 'assets/rainy.png';
        break;
      case 'Clear':
        _backgroundColor = Colors.orange;
        _backgroundImage = 'assets/sunny.png';
        break;
      default:
        _backgroundColor = Colors.white;
        _backgroundImage = 'assets/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima en $_cityName'),
        backgroundColor: _backgroundColor,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _backgroundImage,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Card(
                  color: Colors.white.withOpacity(0.8),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '$_cityName',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Clima: $_weather',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Temperatura: $_temperature°C',
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchWeather,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: _backgroundColor,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    'Actualizar',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
