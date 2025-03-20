import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EsamiPage extends StatefulWidget {
  const EsamiPage({super.key});

  @override
  State<EsamiPage> createState() => _EsamiPageState();
}

class _EsamiPageState extends State<EsamiPage> {
  List<dynamic> _materieConVoto = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaterieConVoto();
  }

  Future<void> _loadMaterieConVoto() async {
    try {
      final cachedMaterie = await _getCachedMaterie();
      if (cachedMaterie.isNotEmpty && mounted) {
        setState(() {
          _materieConVoto =
              cachedMaterie
                  .where((m) => m['voto'] != null && m['voto'] != '')
                  .toList();
          _isLoading = false;
        });
      }

      final fetchedMaterie = await fetchMaterie();
      await _cacheMaterie(fetchedMaterie);

      if (mounted) {
        setState(() {
          _materieConVoto =
              fetchedMaterie
                  .where((m) => m['voto'] != null && m['voto'] != '')
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<List<dynamic>> fetchMaterie() async {
    final url = Uri.parse('http://192.168.1.21:8080/scrape');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Errore: ${response.statusCode}');
    }
  }

  Future<void> _cacheMaterie(List<dynamic> materie) async {
    final prefs = await SharedPreferences.getInstance();
    final materieJson = jsonEncode(materie);
    await prefs.setString('materie_cache', materieJson);
  }

  Future<List<dynamic>> _getCachedMaterie() async {
    final prefs = await SharedPreferences.getInstance();
    final materieJson = prefs.getString('materie_cache');

    if (materieJson != null) {
      return jsonDecode(materieJson);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esami con Voto')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _materieConVoto.isEmpty
              ? const Center(child: Text('Nessuna materia con voto trovata.'))
              : ListView.builder(
                itemCount: _materieConVoto.length,
                itemBuilder: (context, index) {
                  final m = _materieConVoto[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(m['materia'] ?? 'Sconosciuta'),
                      subtitle: Text(
                        'Anno: ${m['anno'] ?? '-'}   Voto: ${m['voto'] ?? '-'}   Crediti: ${m['crediti'] ?? '-'}',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
