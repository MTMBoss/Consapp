import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MaterieService {
  static Future<List<dynamic>> fetchMaterie() async {
    final url = Uri.parse('http://192.168.1.21:8080/scrape');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      return decodedData.map((materia) {
        return {
          'materia': materia['materia'] ?? '',
          'crediti': materia['crediti'] ?? 0,
          'ore_totali': materia['ore_totali'] ?? '0',
          'ore_fatte': materia['ore_fatte'] ?? '0',
          'professore': materia['professore'] ?? '',
          'voto': materia['voto'] ?? '',
          'anno': _parseAnno(materia['anno']),
        };
      }).toList();
    } else {
      throw Exception('Errore: ${response.statusCode}');
    }
  }

  static int _parseAnno(dynamic anno) {
    if (anno is int) {
      return anno;
    } else if (anno is String) {
      return int.tryParse(anno) ?? 0;
    }
    return 0;
  }

  static Future<void> cacheMaterie(List<dynamic> materie) async {
    final prefs = await SharedPreferences.getInstance();
    final materieJson = jsonEncode(materie);
    await prefs.setString('materie_cache', materieJson);
  }

  static Future<List<dynamic>> getCachedMaterie() async {
    final prefs = await SharedPreferences.getInstance();
    final materieJson = prefs.getString('materie_cache');
    if (materieJson != null) {
      return jsonDecode(materieJson);
    } else {
      return [];
    }
  }
}
