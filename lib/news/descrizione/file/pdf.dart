import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/news/descrizione/file/file.dart';

InlineSpan buildPdfLink(String text, String href) {
  return TextSpan(
    children: [
      const WidgetSpan(
        child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
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
