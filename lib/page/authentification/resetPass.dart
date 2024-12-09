import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'signIn.dart'; // Pour convertir les réponses JSON
class ResetPassPage extends StatefulWidget {
  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  // Separate form key for reset password
  final _formKeyResetPass = GlobalKey<FormState>();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variables to control password visibility
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Function to simulate password reset
  void resetPassword() async {
    if (_formKeyResetPass.currentState!.validate()) {
      String newPassword = _newPasswordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Les mots de passe ne correspondent pas !'),
          ),
        );
        return;
      }

      // Préparez l’URL et les données
      final url = Uri.parse("http://192.168.137.35:3000/auth/reset-password");
      final data = {
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };

      try {
        // Récupérez le token depuis SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('accessToken'); // Récupération du token

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : Vous devez vous reconnecter.'),
            ),
          );
          return;
        }

        // Envoyez la requête HTTP POST avec l'autorisation Bearer Token
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Ajoutez le token ici
          },
          body: json.encode(data),
        );

        // Vérifiez la réponse
        print('Code HTTP : ${response.statusCode}');
        print('Réponse : ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mot de passe réinitialisé avec succès !'),
            ),
          );

          // Retour à l'écran de connexion
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()));
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${responseData["message"] ?? "Échec de la réinitialisation"}'),
            ),
          );
        }
      } catch (e) {
        print('Erreur réseau : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau. Veuillez réessayer.'),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/factory2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100), // Space at the top
                  // Logo
                  Image.asset(
                    'assets/logo.png', // Path to the logo image
                    height: 150, // Adjust the size
                  ),
                  SizedBox(height: 20),
                  // Title
                  Text(
                    'Réinitialisation du mot de passe',
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
                  // Reset password input container
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key:
                          _formKeyResetPass, // Use separate form key for reset password
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // New password input
                          TextFormField(
                            controller: _newPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Nouveau mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[300],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isNewPasswordVisible =
                                        !_isNewPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            obscureText: !_isNewPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nouveau mot de passe';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Confirm password input
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Confirmer le mot de passe',
                              hintStyle: TextStyle(color: Colors.grey[300]),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[300],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          // Reset Password Button
                          ElevatedButton(
                            onPressed: resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Réinitialiser le mot de passe',
                              style: TextStyle(fontSize: 18, color: Color(0xFFD42027)),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Return to sign-in page button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[300],size: 14,),
                                onPressed: () {
                                  Navigator.pop(context); // Retour à la page précédente
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
