import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_application_1/news/descrizione.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  List<Map<String, String>> newsList = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final response = await http.get(
      Uri.parse('https://conts.it/it/notizie/news/'),
    );

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final newsCards = document.querySelectorAll('.news-card');

      List<Map<String, String>> fetchedNews = [];

      for (var card in newsCards) {
        var linkElement = card.querySelector('a');
        var dateElement = card.querySelector('.news-date');
        var titleElement = card.querySelector('.news-body');

        if (linkElement != null &&
            dateElement != null &&
            titleElement != null) {
          String href = linkElement.attributes['href'] ?? '';
          String date = dateElement.text.trim();
          String title = titleElement.text.trim();

          fetchedNews.add({
            'href': 'https://conts.it$href',
            'date': date,
            'title': title,
          });
        }
      }

      if (mounted) {
        setState(() {
          newsList = fetchedNews;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          newsList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(newsList[index]['title']!),
                      subtitle: Text(newsList[index]['date']!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DescrizionePage(
                                  url: newsList[index]['href']!,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
