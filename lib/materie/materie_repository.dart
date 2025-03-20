// lib/materie_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'materia_model.dart';

class MaterieRepository {
  Future<List<Materia>> fetchMaterie() async {
    final url = Uri.parse('http://192.168.1.21:8080/scrape');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      List<Materia> materie = [];
      for (var item in decodedData) {
        materie.add(Materia.fromJson(item));
      }
      return materie;
    } else {
      throw Exception('Errore: ${response.statusCode}');
    }
  }

  Future<void> cacheMaterie(List<Materia> materie) async {
    final prefs = await SharedPreferences.getInstance();
    final listMap = materie.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(listMap);
    await prefs.setString('materie_cache', jsonString);
  }

  Future<List<Materia>> getCachedMaterie() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('materie_cache');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => Materia.fromJson(item)).toList();
    }
    return [];
  }
}
