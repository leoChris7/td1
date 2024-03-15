import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Namer App',
            theme: ThemeData(
              useMaterial3: true,
              // appState contient toutes les méthodes de l'application
              colorScheme:
                  ColorScheme.fromSeed(seedColor: appState.getColorScheme()),
            ),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

/** Contient tous les états possible
 * Permet de notifier toutes les notifications de changement
 */
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var randomAccentIndex = Random().nextInt(Colors.accents.length);

  void getNext() {
    current = WordPair.random();
    randomAccentIndex = Random().nextInt(Colors.accents.length);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    }

    notifyListeners();
  }

  MaterialAccentColor getColorScheme() {
    return Colors.accents[randomAccentIndex];
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites.toList();
    // on récupère le thème du contexte.
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(fontSize: 50)),
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          var pair = favorites[index];
          return ListTile(
            // couleur du texte = couleur du contexte
            title: Text(pair.asLowerCase,
                style: TextStyle(color: appState.getColorScheme())),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
          );
        },
      ),
    );
  }
}

// Convertit en stateful pour avoir son propre état
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex =
      0; // Définir selectedIndex en tant que variable d'instance

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('aucun composant pour $selectedIndex');
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
        ],
        currentIndex: selectedIndex,
        // Au clic, on prend la valeur de l'item qu'on a cliqué
        onTap: (value) {
          setState(() {
            // Mettre à jour la valeur de selectedIndex
            selectedIndex = value;
          });
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        // Centrage verticale des éléments
        mainAxisAlignment: MainAxisAlignment.center,

        // Contenu du body
        children: [
          // affiche du texte
          Text('Une idée aléatoire :'),
          // permet d'espacer le texte
          SizedBox(height: 10),
          textWidget(pair: pair),
          // création d'une "column horizontale"
          Row(
            // Indiquer au composant qu'il ne doit pas s'étirer
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ajout d'un bouton avec une icone
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text("J'aime"),
              ),
              SizedBox(width: 10),

              // Ajout d'un bouton normal
              ElevatedButton(
                // EventListener Bouton Appuyé
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Suivant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class textWidget extends StatelessWidget {
  const textWidget({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
