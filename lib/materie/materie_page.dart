// lib/materie_page.dart

import 'package:flutter/material.dart';
import 'materie_repository.dart';
import 'materia_model.dart';

class MateriePage extends StatefulWidget {
  const MateriePage({super.key});

  @override
  State<MateriePage> createState() => _MateriePageState();
}

class _MateriePageState extends State<MateriePage> {
  List<Materia> _materie = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedAnno = 1;
  final MaterieRepository repository = MaterieRepository();

  @override
  void initState() {
    super.initState();
    _loadMaterie();
  }

  Future<void> _loadMaterie() async {
    // Carica dati dalla cache, se disponibili
    final cached = await repository.getCachedMaterie();
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _materie = cached;
        _isLoading = false;
      });
    }
    // Tenta di ottenere dati aggiornati dalla rete
    try {
      final fetched = await repository.fetchMaterie();
      if (fetched.isNotEmpty) {
        await repository.cacheMaterie(fetched);
        if (mounted) {
          setState(() {
            _materie = fetched;
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

  @override
  Widget build(BuildContext context) {
    // Filtra le materie in base all'anno selezionato
    final filtered = _materie.where((m) => m.anno == _selectedAnno).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materie'),
        actions: [
          DropdownButton<int>(
            value: _selectedAnno,
            items: List.generate(
              5,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text('Anno ${index + 1}'),
              ),
            ),
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
              : filtered.isEmpty
              ? const Center(child: Text('Nessuna materia disponibile'))
              : ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final materia = filtered[index];
                  return ListTile(
                    title: Text(materia.materia),
                    subtitle: Text(
                      'Crediti: ${materia.crediti} - Professore: ${materia.professore} - Anno: ${materia.anno} - Voto: ${materia.voto} - Ore Totali: ${materia.oreTotali} - Ore Fatte: ${materia.oreFatte}',
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selezionata materia: ${materia.materia}',
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
