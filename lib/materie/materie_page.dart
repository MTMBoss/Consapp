import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    // Primo passaggio: carica i dati dalla cache (se disponibili)
    final cachedMaterie = await _getCachedMaterie();
    if (cachedMaterie.isNotEmpty && mounted) {
      setState(() {
        _materie = cachedMaterie;
        _isLoading = false;
      });
    }

    // Prova a recuperare i dati aggiornati dalla rete
    try {
      final fetchedMaterie = await fetchMaterie();
      if (fetchedMaterie.isNotEmpty) {
        await _cacheMaterie(fetchedMaterie);
        if (mounted) {
          setState(() {
            _materie = fetchedMaterie;
          });
        }
      }
    } catch (e) {
      // Se la richiesta va in timeout o genera un errore, ed è già presente la cache,
      // lasciamo i dati della cache senza mostrare un errore.
      if (_materie.isEmpty && mounted) {
        setState(() {
          _errorMessage = 'Errore: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<dynamic>> fetchMaterie() async {
    final url = Uri.parse('http://192.168.1.21:8080/scrape');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      // Mappa i dati e prevedi il parsing dell'anno
      return decodedData.map((materia) {
        return {
          'materia': materia['materia'] ?? '',
          'crediti': materia['crediti'] ?? 0,
          'ore_totali': materia['ore_totali'] ?? 0,
          'ore_fatte': materia['ore_fatte'] ?? 0,
          'professore': materia['professore'] ?? '',
          'voto': materia['voto'] ?? '',
          'anno': _parseAnno(materia['anno']),
        };
      }).toList();
    } else {
      throw Exception('Errore: ${response.statusCode}');
    }
  }

  // Metodo per convertire il campo 'anno' in int o fornire un valore di default
  int _parseAnno(dynamic anno) {
    if (anno is int) {
      return anno;
    } else if (anno is String) {
      return int.tryParse(anno) ?? 0;
    }
    return 0; // Valore di default se nullo o non valido
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
        _materie.where((m) {
          final anno = m['anno'] ?? 0; // Valore di default se mancante
          return anno == _selectedAnno;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materie'),
        actions: [
          DropdownButton<int>(
            value: _selectedAnno,
            items: List.generate(5, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('Anno ${index + 1}'),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedAnno = value;
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : materieFiltrate.isEmpty
              ? const Center(child: Text('Nessuna materia disponibile'))
              : ListView.builder(
                itemCount: materieFiltrate.length,
                itemBuilder: (context, index) {
                  final materia = materieFiltrate[index];
                  return ListTile(
                    title: Text(materia['materia']),
                    subtitle: Text(
                      'Crediti: ${materia['crediti']} - Professore: ${materia['professore']} - Anno: ${materia['anno']} - Voto: ${materia['voto']} - Ore Totali: ${materia['ore_totali']} - Ore Fatte: ${materia['ore_fatte']}',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selezionata materia: ${materia['materia']}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
