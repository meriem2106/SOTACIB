import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les réponses JSON
import 'verifyOtp.dart';

class ForgotPassPage extends StatefulWidget {
  @override
  _ForgotPassPageState createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _formKeyForgotPass = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _emailController = TextEditingController();
  String baseUrl = "http://192.168.137.35:3000"; // Votre base URL

  // Fonction pour envoyer l'email à l'API
  Future<void> sendForgotPasswordRequest() async {
    if (!_formKeyForgotPass.currentState!.validate()) {
      return; // Ne pas continuer si le formulaire n'est pas valide
    }
    _formKeyForgotPass.currentState!.save(); // Sauvegarder les données du formulaire

    final email = _emailController.text.trim();
    print('Envoi de l\'email pour mot de passe oublié : $email');
    final url = Uri.parse(baseUrl+"/auth/forget-password");


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Code HTTP : ${response.statusCode}');
      print('Réponse : ${response.body}');
      // Vérifiez si le code HTTP indique une réussite
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final message = responseData['message'] ?? 'Succès';

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Consultez votre boite mail')),
        );

        // Naviguer vers la page OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpPage(email: email),
          ),
        );
      } else {
        // Si le code HTTP n'indique pas une réussite, afficher un message d'erreur
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Erreur inconnue';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Il faut utiliser le meme e-mail')),
        );
      }
    } catch (e) {
      // Gérer les erreurs réseau
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau. Veuillez réessayer.')),
      );
      print('Erreur réseau : $e');
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
            color: Colors.black.withOpacity(0.6),
          ),
          // Contenu principal
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100),
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  // Titre
                  Text(
                    'Mot de passe oublié',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),

                  // Formulaire
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKeyForgotPass,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Texte d'information
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(
                              'Entrez votre adresse e-mail.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                          // Champ e-mail
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Adresse e-mail',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une adresse e-mail valide';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),

                          // Bouton pour envoyer la demande
                          ElevatedButton(
                            onPressed: sendForgotPasswordRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Obtenir le code de vérification',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFD42027),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Bouton de retour
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.grey[300],
                                  size: 14,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              Text(
                                'Retour',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
