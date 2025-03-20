import 'package:flutter/material.dart';

class CreditsWidget extends StatelessWidget {
  final List<dynamic> materieConVoto;

  const CreditsWidget({super.key, required this.materieConVoto});

  @override
  Widget build(BuildContext context) {
    const int totalCredits = 180;

    // Calcoliamo i crediti totalizzati
    int earnedCredits = materieConVoto.fold(0, (sum, m) {
      final creditStr = m['crediti']?.toString() ?? "0";
      final creditValue = int.tryParse(creditStr) ?? 0;
      return sum + creditValue;
    });

    // Calcoliamo la media dei voti escludendo le materie idonee
    double averageScore = 0.0;
    int totalExamsWithVotes = 0;

    for (var materia in materieConVoto) {
      final votoStr = materia['voto']?.toString();
      final tipoMateria =
          materia['tipo']
              ?.toString()
              .toLowerCase(); // Campo per escludere idoneità

      // Escludi "idoneità" e materie con voto vuoto o non valido
      if (tipoMateria != "idoneità" && votoStr != null && votoStr.isNotEmpty) {
        final votoValue = double.tryParse(votoStr);
        if (votoValue != null && votoValue > 0) {
          averageScore += votoValue;
          totalExamsWithVotes++;
        }
      }
    }

    // Calcoliamo la media vera e propria
    if (totalExamsWithVotes > 0) {
      averageScore /= totalExamsWithVotes;
    }

    // Calcoliamo la media in centodecimi
    double averageInHundredths = (averageScore * 11) / 3;

    // Arrotondare i valori
    int roundedAverageScore = averageScore.round();
    int roundedAverageInHundredths = averageInHundredths.round();

    // Calcoliamo il progresso per il cerchio
    double progress = earnedCredits / totalCredits;
    if (progress > 1.0) progress = 1.0;

    // Creiamo il widget per la card con cerchio, crediti, media e centodecimi
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Libretto universitario",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return SizedBox(
                  height: 160, // Dimensione totale del cerchio
                  width: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progresso animato del cerchio
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 140, // Spessore più robusto
                        backgroundColor: Colors.white.withAlpha(
                          (255 * 0.2).round(),
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                      // Testo centrale con crediti
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$earnedCredits",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "/$totalCredits CFU",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withAlpha(
                                  (255 * 0.9).round(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Row per posizionare le medie nei due angoli inferiori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Media: ${averageScore.toStringAsFixed(2)} ($roundedAverageScore)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Centodecimi: ${averageInHundredths.toStringAsFixed(2)} ($roundedAverageInHundredths)",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
