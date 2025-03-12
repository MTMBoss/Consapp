import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_application_1/news/descrizione/descrizione.dart';
import 'package:flutter_application_1/news/aspettonews/aspettonews.dart';
import 'package:flutter_application_1/news/filterdata/filterdata.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  List<Map<String, String>> newsList = [];
  DateTime? selectedDate;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    // Verifichiamo subito se il widget è montato
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final year = selectedDate?.year ?? DateTime.now().year;
      final response = await http.get(
        Uri.parse('https://conts.it/it/notizie/news/?year=$year'),
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

        if (!mounted) return;
        setState(() {
          newsList =
              fetchedNews.where((news) {
                DateTime newsDate = DateTime.parse(
                  FilterData.convertDateFormat(news['date']!),
                );
                return selectedDate == null ||
                    newsDate.isAfter(selectedDate!) ||
                    newsDate.isAtSameMomentAs(selectedDate!);
              }).toList();
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage =
              'Errore durante il recupero dei dati: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Si è verificato un errore: $e';
      });
    } finally {
      // Invece di utilizzare 'return' qui, verifichiamo se il widget è montato e aggiornamo lo stato.
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspettoNews(
      newsList: newsList,
      initialDate: selectedDate ?? DateTime.now(),
      onDateChanged: (newDate) {
        setState(() {
          selectedDate = newDate;
        });
        fetchNews();
      },
      onYearChanged: (newYear) {
        setState(() {
          selectedDate = DateTime(newYear);
        });
        fetchNews();
      },
      onNewsTap: (newsItem) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DescrizionePage(url: newsItem['href']!),
          ),
        );
      },
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
  }
}
