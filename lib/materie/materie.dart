import 'package:flutter/material.dart';

class MateriePage extends StatelessWidget {
  const MateriePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materie Page'),
      ),
      body: Center(
        child: Text('Materie Page Content'),
      ),
    );
  }
}
