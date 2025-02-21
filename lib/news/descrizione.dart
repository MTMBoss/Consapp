import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class DescrizionePage extends StatefulWidget {
  final String url;

  const DescrizionePage({super.key, required this.url});

  @override
  DescrizionePageState createState() => DescrizionePageState();
}

class DescrizionePageState extends State<DescrizionePage> {
  String content = "Caricamento...";

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
      String description = textBlocks.map((e) => e.text.trim()).join("\n\n");

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
          child: Text(content, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
