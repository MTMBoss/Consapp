import 'package:flutter/material.dart';
import 'network_helper.dart';
import 'widget.dart';

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
      final cachedMaterie = await getCachedMaterie();
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
      await cacheMaterie(fetchedMaterie);

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
              ? SingleChildScrollView(
                child: Column(
                  children: [
                    CreditsWidget(materieConVoto: _materieConVoto),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text('Nessuna materia con voto trovata.'),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _materieConVoto.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CreditsWidget(materieConVoto: _materieConVoto);
                  } else {
                    final m = _materieConVoto[index - 1];
                    return GestureDetector(
                      onTap: () {
                        _showDetailBottomSheet(context, m);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['materia'] ?? 'Sconosciuta',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Anno: ${m['anno'] ?? '-'} | Voto: ${m['voto'] ?? '-'} | Crediti: ${m['crediti'] ?? '-'} Sessione: ${m['sessione'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: 1.0,
                                color: Colors.blueAccent,
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, dynamic materia) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 6,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                materia['materia'] ?? 'Sconosciuta',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anno: ${materia['anno'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Voto: ${materia['voto'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Crediti: ${materia['crediti'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Data Esame: ${materia['data_esame'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                'Sessione: ${materia['sessione'] ?? '-'}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
