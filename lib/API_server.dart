import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://mazenmamar.pythonanywhere.com/check-code';



  // دالة إرسال الكود للسيرفر وفحصه
  static Future<String> checkCode(String userCode) async {
    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': userCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? 'لم يتم إرجاع نتائج من السيرفر.';
      } else {
        return 'خطأ في السيرفر: ${response.statusCode}';
      }
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال: $e';
    }
  }
}
