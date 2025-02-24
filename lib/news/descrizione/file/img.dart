// img.dart
import 'package:flutter/material.dart';

Widget buildImage(String imageUrl) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Image.network(
      imageUrl.startsWith('http') ? imageUrl : 'https://conts.it$imageUrl',
      width: 150,
      height: 150,
    ),
  );
}
