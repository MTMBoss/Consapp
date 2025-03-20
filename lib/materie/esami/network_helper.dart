import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchMaterie() async {
  final url = Uri.parse('http://192.168.1.21:8080/scrape');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Errore: ${response.statusCode}');
  }
}

Future<void> cacheMaterie(List<dynamic> materie) async {
  final prefs = await SharedPreferences.getInstance();
  final materieJson = jsonEncode(materie);
  await prefs.setString('materie_cache', materieJson);
}

Future<List<dynamic>> getCachedMaterie() async {
  final prefs = await SharedPreferences.getInstance();
  final materieJson = prefs.getString('materie_cache');

  if (materieJson != null) {
    return jsonDecode(materieJson);
  } else {
    return [];
  }
}
