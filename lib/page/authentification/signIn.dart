import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'forgotPass.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  late String password,email;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String baseUrl ="http://192.168.137.35:3000";

  Future<void> login() async {
    final url = Uri.parse(baseUrl+"/auth/login");

    try {
      print('Tentative de connexion...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Statut HTTP : ${response.statusCode}');
      print('Réponse : ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Erreur côté serveur : ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : E-mail ou mot de passe incorrects')),
        );
      }
    } catch (e) {
      print('Erreur réseau : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/factory2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Superposition semi-transparente
          Container(
            color: Colors.black.withOpacity(0.6), // Superposition sombre
          ),
          // Formulaire de connexion
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100), // Espace en haut
                  // Logo de l'entreprise
                  Image.asset(
                    'assets/logo.png', // Chemin du logo
                    height: 150, // Ajustez la taille
                  ),
                  SizedBox(height: 20),
                  // Titre
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Couleur principale (rouge)
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  // Container pour les champs
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color:
                          Colors.black.withOpacity(0.7), // Arrière-plan sombre
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Champ email
                          TextFormField(
                            onSaved: (value){
                              email=value!;
                            },
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Adresse e-mail',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              filled: true,
                              fillColor:
                                  Colors.grey[850], // Arrière-plan gris foncé
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style:
                                TextStyle(color: Colors.white), // Texte blanc
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value! == null || value!.isEmpty) {
                                return 'Veuillez entrer une adresse e-mail';
                              }
                              if (!RegExp(
                                      r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)) {
                                return 'Veuillez entrer une adresse e-mail valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Champ mot de passe
                          TextFormField(
                            onSaved: (value){
                              password=value!;
                            },
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[300],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value! == null || value!.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value!.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          // Bouton de connexion
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                login();

                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white, // Couleur du bouton (rouge)
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 18, color: Color(0xFFD42027)),
                            ),
                          ),
                          SizedBox(height: 15),
                          // Texte mot de passe oublié
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassPage()),
                              ); // Naviguer vers la page mot de passe oublié
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
