import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/news/file.dart'; // Assicurati che il percorso sia corretto

class DescrizionePage extends StatefulWidget {
  final String url;

  const DescrizionePage({super.key, required this.url});

  @override
  DescrizionePageState createState() => DescrizionePageState();
}

class DescrizionePageState extends State<DescrizionePage> {
  String content = "Caricamento...";
  List<Map<String, String>> docLinks = [];

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

      final docElements = document.querySelectorAll(
        'a[href\$=".pdf"], a[href\$=".doc"], a[href\$=".docx"], img',
      );
      docLinks =
          docElements.map((element) {
            return {
              'href':
                  element.attributes['href'] ?? element.attributes['src'] ?? '',
              'text': element.text.trim(),
              'tagName': element.localName ?? '',
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
        final href = node.attributes['href'] ?? node.attributes['src'] ?? '';
        final text = node.text;

        if (node.localName == 'a' && href != '') {
          if (href.endsWith('.pdf')) {
            spans.add(
              WidgetSpan(
                child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 16),
                alignment: PlaceholderAlignment.middle,
              ),
            );
            spans.add(
              TextSpan(
                text: text,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        final url =
                            href.startsWith('http')
                                ? href
                                : 'https://conts.it$href';
                        downloadFile(url);
                      },
              ),
            );
          } else if (href.endsWith('.doc') || href.endsWith('.docx')) {
            spans.add(
              WidgetSpan(
                child: Icon(Icons.description, color: Colors.blue, size: 16),
                alignment: PlaceholderAlignment.middle,
              ),
            );
            spans.add(
              TextSpan(
                text: text,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        final url =
                            href.startsWith('http')
                                ? href
                                : 'https://conts.it$href';
                        downloadFile(url);
                      },
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: text,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () async {
                        final url =
                            href.startsWith('http')
                                ? href
                                : 'https://conts.it$href';
                        await _launchURL(url);
                      },
              ),
            );
          }
        } else if (node.localName == 'img' && href != '') {
          spans.add(
            WidgetSpan(
              child: Image.network(
                href.startsWith('http') ? href : 'https://conts.it$href',
                width: 150,
                height: 150,
              ),
            ),
          );
        } else {
          spans.add(TextSpan(text: node.text));
        }
      }
    }

    return spans;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } else {
      debugPrint('No application available to open this file.');
    }
  }
}
