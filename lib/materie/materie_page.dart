import 'package:flutter/material.dart';
import 'materia.dart';
import 'add_edit_materia.dart';
import 'materia_detail.dart';

class MateriePage extends StatefulWidget {
  const MateriePage({super.key});

  @override
  MateriePageState createState() => MateriePageState();
}

class MateriePageState extends State<MateriePage> {
  List<Materia> materie = [];
  List<String> insegnantiUsati = [];

  // Calcola un colore in base al progresso: da rosso a verde fino all'80% e bianco al 100%.
  Color getProgressColor(double progress) {
    if (progress < 0.8) {
      return Color.lerp(Colors.red, Colors.green, progress / 0.8)!;
    } else if (progress >= 1.0) {
      return Colors.white;
    } else {
      return Colors.green;
    }
  }

  void addOrUpdateMateria(Materia m, [int? index]) {
    setState(() {
      if (!insegnantiUsati.contains(m.insegnante)) {
        insegnantiUsati.add(m.insegnante);
      }
      if (index == null) {
        materie.add(m);
      } else {
        materie[index] = m;
      }
      // Se promossa, la materia verrà spostata in fondo
      materie.sort((a, b) {
        if ((a.promosso ?? false) && !(b.promosso ?? false)) return 1;
        if (!(a.promosso ?? false) && (b.promosso ?? false)) return -1;
        return 0;
      });
    });
  }

  void deleteMateria(int index) {
    setState(() {
      materie.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: materie.length,
        itemBuilder: (context, index) {
          final materia = materie[index];
          return Dismissible(
            key: UniqueKey(),
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddEditMateriaPage(
                          materia: materia,
                          insegnanti: insegnantiUsati,
                        ),
                  ),
                );
                if (updated != null && updated is Materia) {
                  addOrUpdateMateria(updated, index);
                }
                return false;
              } else if (direction == DismissDirection.endToStart) {
                return await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Conferma cancellazione"),
                        content: const Text("Eliminare questa materia?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Annulla"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Elimina"),
                          ),
                        ],
                      ),
                );
              }
              return false;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                deleteMateria(index);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                // Usa il colore di sfondo della pagina per integrare il tema
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  // Primo livello di ombra neon: luce concentrata sul bordo inferiore
                  BoxShadow(
                    color: getProgressColor(materia.progress).withAlpha(500),
                    offset: const Offset(0, 2), // spostata verso il basso
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                  // Secondo livello di ombra neon: alone diffuso in basso
                  BoxShadow(
                    color: getProgressColor(materia.progress).withAlpha(150),
                    offset: const Offset(0, 4),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  materia.nome,
                  style:
                      (materia.promosso ?? false)
                          ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          )
                          : null,
                ),
                subtitle:
                    (materia.promosso ?? false)
                        ? null
                        : Text(
                          "Insegnante: ${materia.insegnante} - Ore: ${materia.oreCompletate}/${materia.oreTotali}",
                        ),
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MateriaDetailPage(materia: materia),
                    ),
                  );
                  if (updated != null && updated is Materia) {
                    addOrUpdateMateria(updated, index);
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newMateria = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddEditMateriaPage(insegnanti: insegnantiUsati),
            ),
          );
          if (newMateria != null && newMateria is Materia) {
            addOrUpdateMateria(newMateria);
          }
        },
      ),
    );
  }
}
