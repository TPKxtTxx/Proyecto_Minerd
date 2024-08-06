import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:minerd/models/visit.dart';
import 'dart:io';

class VisitDetailScreen extends StatelessWidget {
  final Visit visit;

  VisitDetailScreen({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Visita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código del Centro: ${visit.schoolCode}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Cédula del Director: ${visit.directorId}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Motivo de la Visita: ${visit.reason}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Comentario: ${visit.comment}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(visit.date)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Hora: ${visit.time.format(context)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (visit.photoPath.isNotEmpty)
              Center(
                child: Image.file(
                  File(visit.photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
