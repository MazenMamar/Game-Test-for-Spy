import 'dart:async';
import 'package:flutter/material.dart';

class CodeEditorPage extends StatefulWidget {
  const CodeEditorPage({super.key});

  @override
  State<CodeEditorPage> createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  final TextEditingController _codeController = TextEditingController();
  
  // متغير للتحكم في عرض الواجهة (false = محرر الكود، true = شاشة الأخطاء والنتائج)
  bool _isResultView = false;
  
  Timer? _debounce;
  List<String> errors = [];

  // دالة الفحص اللحظي للكود
  void _onCodeChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkCodeErrors(text);
    });
  }

  // فحص مبدئي للأخطاء (أقواس ناقصة، أو نسيان دالة main)
  void _checkCodeErrors(String code) {
    List<String> newErrors = [];

    int openBrackets = '{'.allMatches(code).length;
    int closeBrackets = '}'.allMatches(code).length;
    if (openBrackets != closeBrackets) {
      newErrors.add("خطأ صياغة: الأقواس المعقوفة {} غير متطابقة.");
    }

    if (code.isNotEmpty && !code.contains('main') && code.length > 20) {
      newErrors.add("تنبيه: يبدو أن الكود يخلو من الدالة الأساسية main().");
    }

    setState(() {
      errors = newErrors;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isResultView ? "شاشة الأخطاء والنتائج" : "محرر الأكواد الذكي"),
        actions: [
          // زر للتبديل بين الواجهتين
          IconButton(
            icon: Icon(_isResultView ? Icons.code : Icons.bug_report),
            tooltip: _isResultView ? "العودة للمحرر" : "عرض الأخطاء",
            onPressed: () {
              setState(() {
                _isResultView = !_isResultView;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isResultView 
            ? _buildResultAndView() // واجهة الأخطاء والنتائج
            : _buildEditorView(),   // واجهة كتابة الكود
      ),
    );
  }

  // --- واجهة 1: محرر الأكواد ---
  Widget _buildEditorView() {
    return Column(
      children: [
        if (errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            color: Colors.red.shade100,
            width: double.infinity,
            child: Text(
              "⚠️ يوجد ${errors.length} خطأ/تنبیه. اضغط على زر الأخطاء بالأعلى للمراجعة.",
              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
            ),
          ),
        Expanded(
          child: TextField(
            controller: _codeController,
            maxLines: null,
            expands: true,
            onChanged: _onCodeChanged,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
            decoration: InputDecoration(
              hintText: "اكتب كود Dart هنا...",
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: errors.isNotEmpty ? Colors.red : Colors.grey,
                  width: errors.isNotEmpty ? 2 : 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- واجهة 2: شاشة عرض الأخطاء والنتائج ---
  Widget _buildResultAndView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "تقرير الأخطاء والفحص اللحظي:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        errors.isEmpty
            ? const Expanded(
                child: Center(
                  child: Text(
                    "🎉 ممتاز! لم يتم رصد أخطاء صياغة ظاهرة حتى الآن.",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: errors.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.error, color: Colors.red),
                        title: Text(errors[index], style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
