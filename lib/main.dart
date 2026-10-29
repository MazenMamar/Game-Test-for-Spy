import 'package:flutter/material.dart';
import 'code_editor_page.dart'; // استدعاء الملف

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Code Playground',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CodeEditorPage(), // جعل محرر الأكواد هو الواجهة الأساسية
    );
  }
}

