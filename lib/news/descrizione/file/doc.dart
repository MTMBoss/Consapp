// doc.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/news/descrizione/file/file.dart';

InlineSpan buildDocLink(String text, String href) {
  return TextSpan(
    children: [
      WidgetSpan(
        child: Icon(Icons.description, color: Colors.blue, size: 16),
        alignment: PlaceholderAlignment.middle,
      ),
      TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer:
            TapGestureRecognizer()
              ..onTap =
                  () => downloadFile(
                    href.startsWith('http') ? href : 'https://conts.it$href',
                  ),
      ),
    ],
  );
}
