import 'package:flutter/material.dart';
import 'biglietti/biglietti.dart';
import 'news/news.dart';
import 'time/time.dart';
import 'materie/materie_page.dart';
import 'pass/pass.dart';
import 'settings/settings.dart';
import 'materie/materie_drawer.dart';

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Per la navigazione globale
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
  late PageController _pageController;

  // Lista delle pagine
  final List<Widget> _pages = [
    PassPage(),
    NewsPage(),
    TimePage(),
    MateriePage(),
    BigliettiPage(),
  ];

  // Lista dei titoli corrispondenti alle pagine
  final List<String> _pageTitles = [
    'Pass',
    'News',
    'Time',
    'Materie',
    'Biglietti',
  ];

  // Esempio di dati per le materie (questi possono essere caricati dinamicamente)
  final List<dynamic> _materie = [
    {'materia': 'Matematica', 'anno': 1, 'voto': '28', 'crediti': 6},
    {'materia': 'Fisica', 'anno': 2, 'voto': '30', 'crediti': 8},
    {'materia': 'Chimica', 'anno': 3, 'voto': '', 'crediti': 4, 'idoneo': true},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigazione tramite il BottomNavigationBar.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // Drawer dinamico in base alla pagina corrente.
  Widget _buildDrawer() {
    switch (_currentIndex) {
      case 0:
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  "Opzioni Pass",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Informazioni Pass"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per "Informazioni Pass"
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Impostazioni Pass"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per "Impostazioni Pass"
                },
              ),
            ],
          ),
        );

      case 1:
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  "Categorie News",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sports),
                title: const Text("Sport"),
                onTap: () {
                  Navigator.pop(context);
                  // Naviga alle notizie di sport
                },
              ),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text("Mondo"),
                onTap: () {
                  Navigator.pop(context);
                  // Naviga alle notizie internazionali
                },
              ),
            ],
          ),
        );

      case 2:
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  "Impostazioni Time",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.access_alarm),
                title: const Text("Alarm Settings"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per le impostazioni dell'allarme
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Schedule Settings"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per la programmazione
                },
              ),
            ],
          ),
        );

      case 3:
        // Passa la lista delle materie dal MainPage al MaterieDrawer
        return MaterieDrawer(materie: _materie);

      case 4:
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  "Opzioni Biglietti",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text("Compra Biglietti"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per comprare biglietti
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Storico Biglietti"),
                onTap: () {
                  Navigator.pop(context);
                  // Logica per lo storico dei biglietti
                },
              ),
            ],
          ),
        );

      default:
        return const Drawer(
          child: Center(child: Text("Nessun contenuto disponibile")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titolo dinamico in base alla pagina attiva
        title: Text(_pageTitles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      // Il Drawer personalizzato di volta in volta.
      drawer: _buildDrawer(),
      // Impostiamo una larghezza ridotta per la gesture
      // di apertura del Drawer, per non interferire con la navigazione di sistema.
      drawerEdgeDragWidth: 40.0,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
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
