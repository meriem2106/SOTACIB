import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CommercialPage()
    );
  }
}

class CommercialPage extends StatefulWidget {
  @override
  _CommercialPageState createState() => _CommercialPageState();
}

class _CommercialPageState extends State<CommercialPage> {
  final List<Map<String, String>> commerciaux = [];
  final List<Map<String, String>> filteredCommercials = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final String baseUrl = 'http://192.168.137.35:3000'; // Replace with your API base URL

  @override
  void initState() {
    super.initState();
    _fetchCommercials();
  }

  Future<void> _fetchCommercials() async {
    final url = Uri.parse('$baseUrl/user/getUsers'); // Replace with your API endpoint
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print("No token found. Redirecting to login...");
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);

        setState(() {
          commerciaux.clear();
          commerciaux.addAll(users
              .where((user) => user['role'] == 'user') // Filter by role 'user'
              .map((user) => {
            'nom': (user['name'] ?? 'N/A').toString(),
            'email': (user['email'] ?? 'N/A').toString(),
            'avatar': (user['image'] != null && user['image'] != '')
                ? '$baseUrl${user['image']}'
                : 'https://via.placeholder.com/150',
          })
              .toList());
          filteredCommercials.clear();
          filteredCommercials.addAll(commerciaux); // Update filtered list
        });
      } else {
        print('Failed to fetch commercials: ${response.body}');
      }
    } catch (e) {
      print('Error fetching commercials: $e');
    }
  }

  Future<void> addCommercial() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');

        if (token == null) {
          print("No token found. Redirecting to login...");
          Navigator.pushReplacementNamed(context, '/');
          return;
        }

        // Create the request
        var uri = Uri.parse('$baseUrl/user/create');
        var request = http.MultipartRequest('POST', uri);

        // Add headers
        request.headers['Authorization'] = 'Bearer $token';

        // Add fields
        request.fields['name'] = nameController.text;
        request.fields['email'] = emailController.text;
        request.fields['password'] = passwordController.text;
        request.fields['role'] = 'user';

        // If image upload is needed, you can add it here
        // For now, we are not uploading an image

        // Send the request
        var response = await request.send();

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Success
          // Fetch updated list
          await _fetchCommercials();

          // Clear the form
          nameController.clear();
          emailController.clear();
          passwordController.clear();

          Navigator.pop(context); // Close Dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Commercial ajouté avec succès')),
          );
        } else {
          // Handle error
          var responseData = await response.stream.bytesToString();
          print('Failed to add commercial: ${response.statusCode} ${responseData}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'ajout du commercial')),
          );
        }
      } catch (e) {
        print('Error adding commercial: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du commercial')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des Commerciaux',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD42027),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Commerciaux Disponibles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // ListView of Commercials
            Expanded(
              child: ListView.builder(
                itemCount: filteredCommercials.length,
                itemBuilder: (context, index) {
                  final commercial = filteredCommercials[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(commercial['avatar']!),
                            radius: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  commercial['nom']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  commercial['email']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show Dialog to Add New Commercial
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black, // Black background for the dialog
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Ajouter un Commercial',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Commercial Name Field
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom Commercial',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD42027)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du commercial';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Commercial Email Field
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD42027)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un email';
                              }
                              if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Commercial Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFFD42027)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons: Add and Cancel
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Annuler",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: addCommercial,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD42027),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text(
                                  'Ajouter',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xFFD42027),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
