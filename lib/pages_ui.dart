import 'API_server.dart';
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

  // متغيرات خاصة بتحليل السيرفر السحابي
  String serverAnalysisResult = "اضغط على زر الفحص السحابي لتحليل الكود...";
  bool _isLoading = false;

  // الفحص اللحظي للكود محلياً (تنبيهات سريعة)
  void _onCodeChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkCodeErrors(text);
    });
  }

  // فحص مبدئي للأخطاء محلياً
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

  // دالة إرسال الكود للسيرفر السحابي واستقبال نتيجة التحليل الحقيقي
  Future<void> _runServerAnalysis() async {
    setState(() {
      _isLoading = true;
      _isResultView = true; // الانتقال التلقائي لواجهة النتائج عند الفحص
    });

    // استدعاء السيرفر المستضاف
    String result = await ApiService.checkCode(_codeController.text);

    setState(() {
      serverAnalysisResult = result;
      _isLoading = false;
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
          // زر الفحص عبر السيرفر السحابي
          if (!_isResultView)
            IconButton(
              icon: const Icon(Icons.cloud_upload, color: Colors.blueAccent),
              tooltip: "فحص عبر السيرفر السحابي",
              onPressed: _runServerAnalysis,
            ),
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
                    "تم رصد ${errors.length} تنبيه/خطأ محلي. راجع تبويب الأخطاء.",
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

  // --- واجهة عرض النتائج القادمة من السيرفر السحابي ---
  Widget _buildResultAndView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            const Text(
              "نتيجة تحليل السيرفر (PythonAnywhere):",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _isLoading ? null : _runServerAnalysis,
              icon: const Icon(Icons.cloud_sync, size: 16),
              label: const Text("إعادة الفحص"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.lightBlueAccent),
                ),
              )
            : Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      serverAnalysisResult,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.lightGreenAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
