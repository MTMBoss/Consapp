import 'package:flutter/material.dart';
import 'materia.dart';

class AddEditMateriaPage extends StatefulWidget {
  final Materia? materia;
  final List<String> insegnanti;
  const AddEditMateriaPage({super.key, this.materia, required this.insegnanti});

  @override
  State<AddEditMateriaPage> createState() => _AddEditMateriaPageState();
}

class _AddEditMateriaPageState extends State<AddEditMateriaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _oreTotaliController;
  late TextEditingController _creditiController;
  late TextEditingController _insegnanteController;
  bool isExam = true; // Tipo di materia (default Esame)

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.materia?.nome ?? '');
    _oreTotaliController = TextEditingController(
      text: widget.materia?.oreTotali.toString() ?? '',
    );
    _creditiController = TextEditingController(
      text: widget.materia?.crediti.toString() ?? '',
    );
    _insegnanteController = TextEditingController(
      text: widget.materia?.insegnante ?? '',
    );
    isExam = widget.materia?.isExam ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _oreTotaliController.dispose();
    _creditiController.dispose();
    _insegnanteController.dispose();
    super.dispose();
  }

  // Funzione per selezionare l'insegnante tramite un dialogo.
  void _selectTeacher() async {
    if (widget.insegnanti.isNotEmpty) {
      String? selected = await showDialog<String>(
        context: context,
        builder:
            (context) => SimpleDialog(
              title: const Text('Seleziona Insegnante'),
              children:
                  widget.insegnanti
                      .map(
                        (teacher) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(context, teacher),
                          child: Text(teacher),
                        ),
                      )
                      .toList(),
            ),
      );
      if (selected != null) {
        setState(() {
          _insegnanteController.text = selected;
        });
      }
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final materia = Materia(
        nome: _nomeController.text,
        oreTotali: int.parse(_oreTotaliController.text),
        crediti: int.parse(_creditiController.text),
        isExam: isExam,
        insegnante: _insegnanteController.text,
        oreCompletate: widget.materia?.oreCompletate ?? 0,
        voto: widget.materia?.voto,
        promosso: widget.materia?.promosso,
      );
      Navigator.pop(context, materia);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.materia == null ? "Aggiungi Materia" : "Modifica Materia",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome Materia"),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Inserisci nome" : null,
              ),
              TextFormField(
                controller: _oreTotaliController,
                decoration: const InputDecoration(labelText: "Ore Totali"),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Inserisci ore" : null,
              ),
              TextFormField(
                controller: _creditiController,
                decoration: const InputDecoration(labelText: "Crediti"),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Inserisci crediti" : null,
              ),
              const SizedBox(height: 10),
              const Text("Tipo Materia:"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Esame"),
                      value: true,
                      groupValue: isExam,
                      onChanged: (val) => setState(() => isExam = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Idoneità"),
                      value: false,
                      groupValue: isExam,
                      onChanged: (val) => setState(() => isExam = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Campo per l'insegnante con suffixIcon che apre il menu di selezione.
              TextFormField(
                controller: _insegnanteController,
                decoration: InputDecoration(
                  labelText: "Nome Insegnante",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _selectTeacher,
                  ),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Inserisci insegnante"
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text("Salva")),
            ],
          ),
        ),
      ),
    );
  }
}
