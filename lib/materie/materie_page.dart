import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'materie_drawer.dart';

class MateriePage extends StatefulWidget {
  const MateriePage({super.key});

  @override
  State<MateriePage> createState() => _MateriePageState();
}

class _MateriePageState extends State<MateriePage> {
  List<dynamic> _materie = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Variabile per tracciare l'anno selezionato
  int _selectedAnno = 1;

  @override
  void initState() {
    super.initState();
    _loadMaterie();
  }

  Future<void> _loadMaterie() async {
    try {
      final cachedMaterie = await _getCachedMaterie();
      if (cachedMaterie.isNotEmpty && mounted) {
        setState(() {
          _materie = cachedMaterie;
          _isLoading = false;
        });
      }

      final fetchedMaterie = await fetchMaterie();
      await _cacheMaterie(fetchedMaterie);

      if (mounted) {
        setState(() {
          _materie = fetchedMaterie;
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
    // Filtra le materie in base all'anno selezionato
    final materieFiltrate =
        _materie
            .where((m) => int.tryParse(m['anno'] ?? '0') == _selectedAnno)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Materie"),
        actions: [
          DropdownButton<int>(
            value: _selectedAnno,
            items: [
              DropdownMenuItem(value: 1, child: const Text('1° Anno')),
              DropdownMenuItem(value: 2, child: const Text('2° Anno')),
              DropdownMenuItem(value: 3, child: const Text('3° Anno')),
            ],
            onChanged: (newAnno) {
              if (newAnno != null) {
                setState(() {
                  _selectedAnno = newAnno;
                });
              }
            },
            underline: Container(), // Nasconde la linea sotto il dropdown
          ),
        ],
      ),
      drawer: MaterieDrawer(
        materie: _materie,
      ), // Passa la lista delle materie al drawer
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : materieFiltrate.isEmpty
              ? const Center(
                child: Text('Nessuna materia trovata per l\'anno selezionato.'),
              )
              : ListView.builder(
                itemCount: materieFiltrate.length,
                itemBuilder: (context, index) {
                  final m = materieFiltrate[index];
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
