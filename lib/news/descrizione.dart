import 'package:flutter/material.dart';

class DescrizionePage extends StatelessWidget {
  final String link;

  const DescrizionePage({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descrizione'),
      ),
      body: Center(
        child: Text('Mostra la descrizione per: $link'),
      ),
    );
  }
}
