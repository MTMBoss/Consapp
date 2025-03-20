import 'package:flutter/material.dart';
import 'esami/esami_page.dart';
import 'materie_page.dart'; // Assicurati di importare il file giusto

class MaterieDrawer extends StatelessWidget {
  const MaterieDrawer({super.key});

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
              // Naviga verso la pagina delle materie
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MateriePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Esami delle Materie"),
            onTap: () {
              Navigator.pop(context); // Chiudi il drawer
              // Naviga verso la pagina degli esami
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const EsamiPage(), // Naviga senza passare parametri
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
