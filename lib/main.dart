import 'package:flutter/material.dart';
import 'package:minerd/screens/home_screen.dart';
import 'package:minerd/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MINERD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.red,
        hintColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }
}
