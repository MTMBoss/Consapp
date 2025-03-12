import 'package:flutter/material.dart';
import 'materia.dart';

class MateriaDetailPage extends StatefulWidget {
  final Materia materia;
  const MateriaDetailPage({super.key, required this.materia});

  @override
  State<MateriaDetailPage> createState() => _MateriaDetailPageState();
}

class _MateriaDetailPageState extends State<MateriaDetailPage> {
  late Materia materia;
  final _votoController = TextEditingController();
  bool promosso = false;

  @override
  void initState() {
    super.initState();
    materia = widget.materia;
    if (!materia.isExam && (materia.promosso ?? false)) {
      promosso = true;
    }
    if (materia.voto != null) {
      _votoController.text = materia.voto.toString();
    }
  }

  @override
  void dispose() {
    _votoController.dispose();
    super.dispose();
  }

  // Al tocco dell'icona +, incrementa di 1 le ore completate (fino al massimo previsto)
  void _incrementOre() {
    setState(() {
      if (materia.oreCompletate < materia.oreTotali) {
        materia.oreCompletate++;
      }
    });
  }

  void _save() {
    if (materia.isExam) {
      if (_votoController.text.isNotEmpty) {
        materia.voto = int.tryParse(_votoController.text);
      }
    } else {
      materia.promosso = promosso;
    }
    Navigator.pop(context, materia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dettaglio: ${materia.nome}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mostriamo tutte le informazioni
            Text(
              "Materia: ${materia.nome}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Insegnante: ${materia.insegnante}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Ore: ${materia.oreCompletate}/${materia.oreTotali}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Crediti: ${materia.crediti}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Tipo: ${materia.isExam ? "Esame" : "Idoneità"}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (materia.isExam)
              TextField(
                controller: _votoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Voto (Esame)"),
              )
            else
              SwitchListTile(
                title: const Text("Promosso"),
                value: promosso,
                onChanged: (val) => setState(() => promosso = val),
              ),
            const Divider(height: 20),
            // Sezione per aggiungere ore con un'icona,
            // eliminando così il bisogno di digitare manualmente le ore.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Aggiungi ora:", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  onPressed: _incrementOre,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Salva")),
          ],
        ),
      ),
    );
  }
}
