import 'package:flutter/material.dart';

// Classe Esame
class Esame {
  final String materia;
  final int crediti;
  final int? anno;
  final String? voto;
  final bool? idoneo;

  Esame({
    required this.materia,
    required this.crediti,
    this.anno,
    this.voto,
    this.idoneo,
  });

  // Metodo per convertire da JSON a Esame
  factory Esame.fromMap(Map<String, dynamic> map) {
    return Esame(
      materia: map['materia'] ?? 'Sconosciuta',
      crediti: int.tryParse(map['crediti'] ?? '0') ?? 0,
      anno: int.tryParse(map['anno'] ?? '0'),
      voto: map['voto'],
      idoneo: map['idoneo'] == true,
    );
  }

  // Metodo per convertire Esame in JSON
  Map<String, dynamic> toMap() {
    return {
      'materia': materia,
      'crediti': crediti.toString(),
      'anno': anno?.toString() ?? '',
      'voto': voto ?? '',
      'idoneo': idoneo ?? false,
    };
  }
}

// Pagina EsamiPage
class EsamiPage extends StatelessWidget {
  final List<Esame> esami;

  const EsamiPage({super.key, required this.esami});

  @override
  Widget build(BuildContext context) {
    // Filtra gli esami con voto o idoneità
    final esamiConVotoOIdoneo =
        esami
            .where(
              (esame) =>
                  esame.voto != null && esame.voto!.isNotEmpty ||
                  (esame.idoneo ?? false),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Esami Materie")),
      body:
          esamiConVotoOIdoneo.isEmpty
              ? const Center(
                child: Text("Non ci sono esami con voto o idoneità."),
              )
              : ListView.builder(
                itemCount: esamiConVotoOIdoneo.length,
                itemBuilder: (context, index) {
                  final esame = esamiConVotoOIdoneo[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      title: Text(esame.materia),
                      subtitle: Text(
                        'Anno: ${esame.anno ?? "-"}   Crediti: ${esame.crediti}   '
                        'Voto: ${esame.voto ?? "Idoneo"}',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
