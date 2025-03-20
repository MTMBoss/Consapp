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

  // Selezione dell'anno
  int _selectedAnno = 1;

  @override
  void initState() {
    super.initState();
    _loadMaterie();
  }

  Future<void> _loadMaterie() async {
    // Carica i dati dalla cache, se presenti
    final cachedMaterie = await _getCachedMaterie();
    if (cachedMaterie.isNotEmpty && mounted) {
      setState(() {
        _materie = cachedMaterie;
        _isLoading = false;
      });
    }

    // Recupera i dati aggiornati dalla rete
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

  int _parseAnno(dynamic anno) {
    if (anno is int) {
      return anno;
    } else if (anno is String) {
      return int.tryParse(anno) ?? 0;
    }
    return 0;
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
          final anno = m['anno'] ?? 0;
          return anno == _selectedAnno;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materie'),
        actions: [
          DropdownButton<int>(
            value: _selectedAnno,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedAnno = value;
                });
              }
            },
            items: List.generate(5, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('Anno ${index + 1}'),
              );
            }),
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

                  // Calcola il rapporto tra ore fatte e ore totali per il progress indicator
                  final totalHours =
                      double.tryParse(materia['ore_totali'].toString()) ?? 0.0;
                  final doneHours =
                      double.tryParse(materia['ore_fatte'].toString()) ?? 0.0;
                  final ratio = totalHours > 0 ? doneHours / totalHours : 0.0;
                  final progressColor =
                      Color.lerp(Colors.red, Colors.green, ratio) ?? Colors.red;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Mostra un modal bottom sheet con i dettagli
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            materia['materia'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Anno: ${materia['anno']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              strokeWidth: 8,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              value: ratio,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    progressColor,
                                                  ),
                                            ),
                                            Text(
                                              '${(ratio * 100).round()}%',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Crediti: ${materia['crediti']}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Professore: ${materia['professore']}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Voto: ${materia['voto']}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ore Totali: ${materia['ore_totali']} - Ore Fatte: ${materia['ore_fatte']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    LinearProgressIndicator(
                                      value: ratio,
                                      minHeight: 8,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progressColor,
                                      ),
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Indicatore circolare di progresso
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      backgroundColor: Colors.grey.shade300,
                                      value: ratio,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progressColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${(ratio * 100).round()}%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Informazioni riepilogative
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      materia['materia'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.school,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Anno: ${materia['anno']}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
