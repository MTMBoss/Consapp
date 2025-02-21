import 'package:flutter/material.dart';

class BigliettiPage extends StatelessWidget {
  const BigliettiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biglietti Page'),
      ),
      body: Center(
        child: Text('Biglietti Page Content'),
      ),
    );
  }
}
