import 'package:flutter/material.dart';
import 'materie_service.dart';
import 'materie_card.dart';

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
    try {
      final materie = await MaterieService.fetchMaterie();
      setState(() {
        _materie = materie;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final materieFiltrate =
        _materie.where((m) => m['anno'] == _selectedAnno).toList();

    return Scaffold(
      appBar: AppBar(
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
            items: List.generate(3, (index) {
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
                  return MaterieCard(materia: materieFiltrate[index]);
                },
              ),
    );
  }
}
