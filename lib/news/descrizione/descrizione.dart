// descrizione.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/news/descrizione/file/pdf.dart';
import 'package:flutter_application_1/news/descrizione/file/doc.dart';
import 'package:flutter_application_1/news/descrizione/file/img.dart';

class DescrizionePage extends StatefulWidget {
  final String url;

  const DescrizionePage({super.key, required this.url});

  @override
  DescrizionePageState createState() => DescrizionePageState();
}

class DescrizionePageState extends State<DescrizionePage> {
  String content = "Caricamento...";
  String imageUrl = '';

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

      final imgElement = document.querySelector('.gallery-block a');
      if (imgElement != null) {
        String imgSrc = imgElement.attributes['href'] ?? '';
        if (imgSrc.isNotEmpty && !imgSrc.startsWith('http')) {
          imageUrl =
              'https://conts.it$imgSrc'; // Modifica l'URL con il dominio corretto
        } else {
          imageUrl = imgSrc;
        }
      }

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
              if (imageUrl.isNotEmpty) buildImage(imageUrl),
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

        if (node.localName == 'a' && href.isNotEmpty) {
          if (href.endsWith('.pdf')) {
            spans.add(buildPdfLink(text, href));
          } else if (href.endsWith('.doc') || href.endsWith('.docx')) {
            spans.add(buildDocLink(text, href));
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
                      ..onTap =
                          () => _launchURL(
                            href.startsWith('http')
                                ? href
                                : 'https://conts.it$href',
                          ),
              ),
            );
          }
        } else {
          spans.add(TextSpan(text: node.text));
        }
      }
    }

    return spans;
  }

  Widget buildImage(String url) {
    return GestureDetector(
      onTap: () => openFullScreenImage(context, url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget:
              (context, url, error) => const Text(
                'Immagine non disponibile',
                style: TextStyle(color: Colors.red),
              ),
        ),
      ),
    );
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
