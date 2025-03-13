import 'package:flutter/material.dart';

class MateriePage extends StatelessWidget {
  const MateriePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista Materie")),
      body: Center(
        child: Text(
          "Qui verrà mostrata la lista delle materie.",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
