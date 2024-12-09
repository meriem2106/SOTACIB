import 'package:flutter/material.dart';


import 'admin/AjouterCimenterie.dart';
import 'admin/ajouterCommercial.dart';
import 'admin/listeProduit.dart';
import 'page/authentification/forgotPass.dart';
import 'page/authentification/resetPass.dart';
import 'page/authentification/signIn.dart';
import 'page/home.dart';
import 'page/home_page.dart';
import 'page/screens/planification.dart';
import 'page/screens/visites/nouvellevisite.dart';
import 'page/statistics/disponibiliteProduit.dart';
import 'page/statistics/evolutionPrix.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion',
      debugShowCheckedModeBanner: false, // Supprime le debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/', // Route initiale de l'application
      routes: {
        '/': (context) => SignInPage(), // Page de connexion
        '/home': (context) => HomePage(), // Page d'accueil
        '/addVisite': (context) => NouvelleVisite(), // Page d'accueil
        '/addCommercial': (context) => CommercialPage(), // Page d'accueil
        '/addCimenterie': (context) => ConcurrentPage(), // Page d'accueil
        '/produits': (context) => ProduitsPage(), // Page d'accueil
        '/disponibilite': (context) => Evolutionprix(),
        '/planification': (context) => Planifications(), // Page d'accueil


      },
    );
  }
}
