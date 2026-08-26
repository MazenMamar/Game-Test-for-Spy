import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'S',
            style: TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
