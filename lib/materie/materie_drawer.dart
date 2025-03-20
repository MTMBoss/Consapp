import 'package:flutter/material.dart';
import 'materie_page.dart';
import 'esami_page.dart';

class MaterieDrawer extends StatelessWidget {
  final List<dynamic> materie; // Lista di materie da passare

  const MaterieDrawer({super.key, required this.materie});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Opzioni Materie",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Lista Materie"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MateriePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Esami Materie"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EsamiPage(
                        esami:
                            materie
                                .map((m) => Esame.fromMap(m))
                                .where(
                                  (esame) =>
                                      esame.voto != null ||
                                      (esame.idoneo ?? false),
                                )
                                .toList(), // Filtra solo le materie con voto o idoneità
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
