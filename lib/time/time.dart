import 'package:flutter/material.dart';

class TimePage extends StatelessWidget {
  const TimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Page'),
      ),
      body: Center(
        child: Text('Time Page Content'),
      ),
    );
  }
}
