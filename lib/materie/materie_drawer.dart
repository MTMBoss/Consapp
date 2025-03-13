import 'package:flutter/material.dart';
import 'materie_page.dart';

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
              Navigator.pop(context); // Chiude il drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MateriePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Modifica Materie"),
            onTap: () {
              Navigator.pop(context);
              // Logica per la modifica delle materie (eventualmente un'altra pagina)
            },
          ),
        ],
      ),
    );
  }
}
