import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // مهم عشان زر النسخ

class PagesUiPage extends StatefulWidget {
  const PagesUiPage({super.key});

  @override
  State<PagesUiPage> createState() => _PagesUiPageState();
}

class _PagesUiPageState extends State<PagesUiPage> {
  final TextEditingController _codeController = TextEditingController();
  
  bool _isResultView = false;
  Timer? _debounce;
  List<String> errors = [];

  // الفحص اللحظي للكود
  void _onCodeChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkCodeErrors(text);
    });
  }

  // فحص مبدئي للأخطاء
  void _checkCodeErrors(String code) {
    List<String> newErrors = [];

    int openBrackets = '{'.allMatches(code).length;
    int closeBrackets = '}'.allMatches(code).length;
    if (openBrackets != closeBrackets) {
      newErrors.add("خطأ صياغة: الأقواس المعقوفة {} غير متطابقة.");
    }

    if (code.isNotEmpty && !code.contains('main') && code.length > 20) {
      newErrors.add("تنبيه: الكود يخلو من الدالة الأساسية main().");
    }

    setState(() {
      errors = newErrors;
    });
  }

  // دالة نسخ الكود للحافظة
  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _codeController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم نسخ الكود بنجاح! جاهز للتجربة الخارجية."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
      backgroundColor: const Color(0xFF1E1E1E), // ثيم VS Code الداكن
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              _isResultView ? Icons.bug_report : Icons.code,
              color: _isResultView ? Colors.orangeAccent : Colors.lightBlueAccent,
            ),
            const SizedBox(width: 10),
            Text(
              _isResultView ? "تقرير الأخطاء" : "محرر الأكواد الذكي",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // زر نسخ الكود
          if (!_isResultView)
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.lightGreenAccent),
              tooltip: "نسخ الكود",
              onPressed: _copyCodeToClipboard,
            ),
          // زر تبديل الواجهات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isResultView ? Colors.blueGrey : Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isResultView = !_isResultView;
                });
              },
              icon: Icon(_isResultView ? Icons.code : Icons.bug_report, size: 18),
              label: Text(_isResultView ? "المحرر" : "الأخطاء (${errors.length})"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isResultView 
            ? _buildResultAndView() 
            : _buildEditorView(),   
      ),
    );
  }

  // --- واجهة محرر الأكواد بتصميم VS Code ---
  Widget _buildEditorView() {
    return Column(
      children: [
        if (errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              border: Border.all(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "تم رصد ${errors.length} تنبيه/خطأ. راجع تبويب الأخطاء.",
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF252526),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errors.isNotEmpty ? Colors.redAccent : Colors.grey.shade800,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _codeController,
              maxLines: null,
              expands: true,
              onChanged: _onCodeChanged,
              style: const TextStyle(
                fontFamily: 'monospace', 
                fontSize: 15, 
                color: Color(0xFFD4D4D4), // لون الكود النموذجي
              ),
              decoration: const InputDecoration(
                hintText: "// اكتب كود Dart هنا...\nvoid main() {\n  print('Hello World');\n}",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- واجهة عرض الأخطاء ---
  Widget _buildResultAndView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "نتائج التحليل الفوري:",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        errors.isEmpty
            ? const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
                      SizedBox(height: 16),
                      Text(
                        "ممتاز! الكود خالي من أخطاء الصياغة الظاهرة.",
                        style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: errors.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.error_outline, color: Colors.redAccent),
                        title: Text(
                          errors[index],
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
