import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_application_1/news/file.dart'; // Assicurati che il percorso sia corretto

class DescrizionePage extends StatefulWidget {
  final String url;

  const DescrizionePage({super.key, required this.url});

  @override
  DescrizionePageState createState() => DescrizionePageState();
}

class DescrizionePageState extends State<DescrizionePage> {
  String content = "Caricamento...";
  List<Map<String, String>> pdfLinks = [];

  @override
  void initState() {
    super.initState();
    fetchDescription();
  }

  Future<void> fetchDescription() async {
    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final titleElement = document.querySelector('h1');
      final textBlocks = document.querySelectorAll(
        '.text-block p, .text-block ul li',
      );

      String title = titleElement?.text.trim() ?? 'Nessun titolo';
      String description = textBlocks
          .map((e) => e.innerHtml.trim())
          .join("\n\n");

      final pdfElements = document.querySelectorAll('a[href\$=".pdf"]');
      pdfLinks =
          pdfElements.map((element) {
            return {
              'href': element.attributes['href'] ?? '',
              'text': element.text.trim(),
            };
          }).toList();

      setState(() {
        content = "$title\n\n$description";
      });
    } else {
      setState(() {
        content = "Errore nel caricamento della descrizione.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Descrizione")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  children: _buildTextSpans(content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(String html) {
    final document = parser.parseFragment(html);
    List<InlineSpan> spans = [];

    for (var node in document.nodes) {
      if (node is dom.Text) {
        spans.add(TextSpan(text: node.text));
      } else if (node is dom.Element) {
        if (node.localName == 'a' && node.attributes['href'] != null) {
          final href = node.attributes['href']!;
          final text = node.text;
          if (href.endsWith('.pdf')) {
            spans.add(
              WidgetSpan(
                child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                alignment: PlaceholderAlignment.middle,
              ),
            );
          }
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      downloadFile('https://conts.it$href');
                    },
            ),
          );
        } else {
          spans.add(TextSpan(text: node.text));
        }
      }
    }

    return spans;
  }
}
