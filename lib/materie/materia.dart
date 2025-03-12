class Materia {
  String nome;
  int oreTotali;
  int oreCompletate;
  int crediti;
  bool isExam;
  int? voto; // per le materie d'esame
  bool? promosso; // per le materie da idoneità (true=promosso, false=bocciato)
  String insegnante;

  Materia({
    required this.nome,
    required this.oreTotali,
    this.oreCompletate = 0,
    required this.crediti,
    required this.isExam,
    this.voto,
    this.promosso,
    required this.insegnante,
  });

  double get progress => oreTotali > 0 ? oreCompletate / oreTotali : 0;
}
