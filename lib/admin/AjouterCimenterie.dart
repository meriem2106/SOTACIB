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
        home: ConcurrentPage()
    );
  }
}

class ConcurrentPage extends StatefulWidget {
  @override
  _ConcurrentPageState createState() => _ConcurrentPageState();
}

class _ConcurrentPageState extends State<ConcurrentPage> {
  final List<Map<String, String>> concurrents = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController abbreviationController = TextEditingController();

  final String baseUrl = 'http://192.168.137.35:3000'; // Replace with your API base URL

  @override
  void initState() {
    super.initState();
    _fetchConcurrents();
  }

  Future<void> _fetchConcurrents() async {
    final url = Uri.parse('$baseUrl/concurent/fetchConcurent');
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
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          concurrents.clear();
          concurrents.addAll((data['concurent'] as List<dynamic>).map((item) {
            return {
              'id': item['_id'].toString(),
              'nom': item['nom']?.toString() ?? 'N/A',
              'abreviation': item['abreviation']?.toString() ?? 'N/A',
            };
          }).toList());
        });
      } else {
        print('Failed to fetch concurrents: ${response.body}');
      }
    } catch (e) {
      print('Error fetching concurrents: $e');
    }
  }

  Future<void> addConcurrent() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('$baseUrl/concurent/ajouterConcurent');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print("No token found. Redirecting to login...");
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'nom': nameController.text,
            'abreviation': abbreviationController.text,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Success
          await _fetchConcurrents();

          // Clear the form
          nameController.clear();
          abbreviationController.clear();

          Navigator.pop(context); // Close Dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Concurrent ajouté avec succès')),
          );
        } else {
          print('Failed to add concurrent: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'ajout du concurrent')),
          );
        }
      } catch (e) {
        print('Error adding concurrent: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du concurrent')),
        );
      }
    }
  }

  Future<void> deleteConcurrent(String id) async {
    final url = Uri.parse('$baseUrl/concurent/delete/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print("No token found. Redirecting to login...");
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success
        await _fetchConcurrents();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Concurrent supprimé avec succès')),
        );
      } else {
        print('Failed to delete concurrent: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression du concurrent')),
        );
      }
    } catch (e) {
      print('Error deleting concurrent: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du concurrent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des Concurrents',
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
              'Concurrents Disponibles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // ListView of Concurrents
            Expanded(
              child: ListView.builder(
                itemCount: concurrents.length,
                itemBuilder: (context, index) {
                  final concurrent = concurrents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        concurrent['nom']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(concurrent['abreviation']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteConcurrent(concurrent['id']!),
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
          // Show Dialog to Add New Concurrent
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
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Ajouter une Cimenterie',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Nom Field
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
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
                              return 'Veuillez entrer le nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Abbreviation Field
                        TextFormField(
                          controller: abbreviationController,
                          decoration: InputDecoration(
                            labelText: 'Abréviation',
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
                              return 'Veuillez entrer l\'abréviation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
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
                              onPressed: addConcurrent,
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
