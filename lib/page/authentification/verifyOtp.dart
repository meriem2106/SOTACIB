import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'resetPass.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  VerifyOtpPage({required this.email});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());
  String? errorMessage;

  // Obtenez l'OTP saisi
  String getOtpFromControllers() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Vérifiez l'OTP avec le backend
  Future<void> verifyOtp() async {
    String enteredOtp = getOtpFromControllers();
    final url = Uri.parse("http://192.168.137.35:3000/auth/verify-otp");

    print('Début de la vérification OTP');
    print('OTP saisi : $enteredOtp');
    print('Envoi de la requête au backend : $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'otp': enteredOtp}),
      );

      print('Code HTTP reçu : ${response.statusCode}');
      print('Réponse brute : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Réponse décodée : $responseData');

        if (responseData['message'] == 'OTP verified successfully') {
          print('OTP vérifié avec succès');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP vérifié avec succès!')),
          );

          // Naviguer vers la page de réinitialisation
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPassPage()),
          );
        } else {
          print('Erreur inattendue dans la réponse : ${responseData['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur inattendue : ${responseData['message']}')),
          );
        }
      } else {
        print('OTP invalide ou erreur côté serveur');
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${responseData["message"] ?? "OTP invalide"}')),
        );
      }
    } catch (e) {
      print('Erreur réseau ou exception : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau. Veuillez réessayer.')),
      );
    }
  }




  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/factory2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100),
                  Image.asset(
                    'assets/logo.png',
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Vérification du code',
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
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Entrez le code de vérification envoyé à votre e-mail.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        if (errorMessage != null) ...[
                          SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Color(0xFFD42027),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return _buildOtpBox(index);
                          }),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // White button
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Vérifier le code',
                            style: TextStyle(
                              fontSize: 18,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        style: TextStyle(color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text, // Utilise le clavier par défaut
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        autocorrect: false, // Désactiver l'autocorrection
        enableSuggestions: false, // Désactiver les suggestions
        onChanged: (value) {
          // Vérifier si la valeur est un nombre
          if (value.isNotEmpty && !RegExp(r'^[0-9]$').hasMatch(value)) {
            setState(() {
              errorMessage = "Seuls les chiffres sont autorisés.";
            });
            _otpControllers[index].clear(); // Effacer l'entrée
          } else {
            setState(() {
              errorMessage = null; // Réinitialiser le message d'erreur
            });

            // Déplacer le focus
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }
}