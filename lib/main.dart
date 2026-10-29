import 'package:flutter/material.dart';
import 'pages_ui.dart'; // استدعاء ملفك الجديد

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Code Playground',
      theme: ThemeData(
        brightness: Brightness.dark, // مظهر داكن يناسب المبرمجين
        primarySwatch: Colors.blue,
      ),
      home: const PagesUiPage(), // استدعاء الصفحة الأساسية
    );
  }
}
