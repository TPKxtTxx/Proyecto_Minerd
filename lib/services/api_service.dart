import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:minerd/models/director.dart';

class ApiService {
  static Future<Director?> searchDirectorByCedula(String cedula) async {
    final response = await http.get(
      Uri.parse('https://api.example.com/directors/$cedula'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Director.fromJson(json);
    } else {
      return null;
    }
  }
}
