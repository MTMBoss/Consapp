import 'package:flutter/material.dart';
import 'biglietti/biglietti.dart';
import 'news/news.dart';
import 'time/time.dart';
import 'materie/materie.dart';
import 'pass/pass.dart';
import 'settings/settings.dart';

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Aggiunto per la navigazione globale
      title: 'MyApp',
      theme: ThemeData.dark(),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    PassPage(),
    NewsPage(),
    TimePage(),
    MateriePage(),
    BigliettiPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel, color: Colors.blue),
            label: 'Pass',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.blue),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time, color: Colors.blue),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Colors.blue),
            label: 'Materie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number, color: Colors.blue),
            label: 'Biglietti',
          ),
        ],
      ),
    );
  }
}
