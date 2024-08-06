import 'package:flutter/material.dart';
import 'package:minerd/screens/incident_report_screen.dart';
import 'package:minerd/screens/incident_list_screen.dart';
import 'package:minerd/screens/about_screen.dart';
import 'package:minerd/screens/school_search_screen.dart';
import 'package:minerd/screens/director_search_screen.dart';
import 'package:minerd/screens/visit_register_screen.dart';
import 'package:minerd/screens/visit_list_screen.dart';
import 'package:minerd/screens/visit_map_screen.dart';
import 'package:minerd/screens/news_screen.dart';
import 'package:minerd/screens/weather_screen.dart';
import 'package:minerd/screens/horoscope_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            _buildGridTile(context, 'Registrar Incidencia', Icons.add_circle, IncidentReportScreen()),
            _buildGridTile(context, 'Lista de Incidencias', Icons.list, IncidentListScreen()),
            _buildGridTile(context, 'Horóscopo', Icons.star, HoroscopeScreen()),
            _buildGridTile(context, 'Buscar Escuela', Icons.school, SchoolSearchScreen()),
            _buildGridTile(context, 'Buscar Director', Icons.person_search, DirectorSearchScreen()),
            _buildGridTile(context, 'Registrar Visita', Icons.location_on, VisitRegisterScreen()),
            _buildGridTile(context, 'Lista de Visitas', Icons.map, VisitListScreen()),
            _buildGridTile(context, 'Mapa de Visitas', Icons.map, VisitMapScreen()),
            _buildGridTile(context, 'Noticias', Icons.article, NewsScreen()),
            _buildGridTile(context, 'Clima', Icons.wb_sunny, WeatherScreen()),
            _buildGridTile(context, 'Acerca de', Icons.info, AboutScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        color: Colors.grey[850], // Fondo gris oscuro para el Card
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.white), // Ícono blanco
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.white), // Texto blanco
            ),
          ],
        ),
      ),
    );
  }
}
