import 'package:flutter/material.dart';
import 'package:minerd/models/incident.dart';
import 'package:minerd/screens/incident_detail_screen.dart';
import 'package:minerd/services/db_service.dart';

class IncidentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Incidencias'),
        backgroundColor: Color(0xFF0033A0), // Azul
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _confirmDeleteAll(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Incidencia>>(
        future: DBService.incidencias(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No hay incidencias registradas.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final incidencia = snapshot.data![index];
              return Card(
                color: Colors.white, // Fondo blanco para el card
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 5, // Sombra sutil
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(
                    incidencia.titulo,
                    style: TextStyle(color: Color(0xFF0033A0), fontWeight: FontWeight.bold), // Azul
                  ),
                  subtitle: Text(
                    incidencia.centroEducativo,
                    style: TextStyle(color: Color(0xFF0033A0)), // Azul
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => IncidentDetailScreen(incidencia: incidencia),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar todas las incidencias?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DBService.deleteAllIncidencias();
      // Refrescar la pantalla después de eliminar las incidencias
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todas las incidencias han sido eliminadas.')),
      );
    }
  }
}
