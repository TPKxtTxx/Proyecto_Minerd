import 'package:flutter/material.dart';

class Visit {
  final String? id;
  final String directorId;
  final String schoolCode;
  final String reason;
  final String photoPath;
  final String comment;
  final String audioPath;
  final double latitude;
  final double longitude;
  final DateTime date;
  final TimeOfDay time;

  Visit({
    this.id,
    required this.directorId,
    required this.schoolCode,
    required this.reason,
    required this.photoPath,
    required this.comment,
    required this.audioPath,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'directorId': directorId,
      'schoolCode': schoolCode,
      'reason': reason,
      'photoPath': photoPath,
      'comment': comment,
      'audioPath': audioPath,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
    };
  }
  

  static Visit fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id'],
      directorId: map['directorId'],
      schoolCode: map['schoolCode'],
      reason: map['reason'],
      photoPath: map['photoPath'],
      comment: map['comment'],
      audioPath: map['audioPath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
    );
  }
}
