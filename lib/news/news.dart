import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Page'),
      ),
      body: Center(
        child: Text('News Page Content'),
      ),
    );
  }
}
