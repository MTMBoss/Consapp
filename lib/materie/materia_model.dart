// lib/materia_model.dart

class Materia {
  final String materia;
  final int crediti;
  final String oreTotali;
  final String oreFatte;
  final String professore;
  final String voto;
  final int anno;

  Materia({
    required this.materia,
    required this.crediti,
    required this.oreTotali,
    required this.oreFatte,
    required this.professore,
    required this.voto,
    required this.anno,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      materia: json['materia'] ?? '',
      crediti:
          json['crediti'] is int
              ? json['crediti']
              : int.tryParse(json['crediti'].toString()) ?? 0,
      oreTotali: json['ore_totali']?.toString() ?? '',
      oreFatte: json['ore_fatte']?.toString() ?? '',
      professore: json['professore'] ?? '',
      voto: json['voto'] ?? '',
      anno:
          json['anno'] is int
              ? json['anno']
              : int.tryParse(json['anno'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materia': materia,
      'crediti': crediti,
      'ore_totali': oreTotali,
      'ore_fatte': oreFatte,
      'professore': professore,
      'voto': voto,
      'anno': anno,
    };
  }
}
