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
      home: ProduitsPage(),
    );
  }
}

class ProduitsPage extends StatefulWidget {
  @override
  _ProduitsPageState createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> filteredProduits = [];
  List<Map<String, dynamic>> concurrents = [];
  String? selectedConcurrentId; // For filtering
  String? selectedConcurrentForAdd; // For adding

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final String baseUrl = 'http://192.168.137.35:3000';

  @override
  void initState() {
    super.initState();
    _fetchConcurrents();
    _fetchProduits();
  }

  Future<void> _fetchProduits() async {
    final url = Uri.parse('$baseUrl/produit/fetchProduits');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
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
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          produits = data.map((item) {
            return {
              'id': item['_id'],
              'nom': item['nom'],
              'prix': item['prix'].toString(),
              'concurrentId': item['concurent']?['_id'],
              'concurrentNom': item['concurent']?['nom'] ?? 'Unknown',
            };
          }).toList();
          filteredProduits = produits; // Show all products by default
        });
      } else {
        print('Failed to fetch produits: ${response.body}');
      }
    } catch (e) {
      print('Error fetching produits: $e');
    }
  }

  Future<void> _fetchConcurrents() async {
    final url = Uri.parse('$baseUrl/concurent/fetchConcurent');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
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
          concurrents = (data['concurent'] as List<dynamic>).map((item) {
            return {
              'id': item['_id'],
              'nom': item['nom'],
            };
          }).toList();
        });
      } else {
        print('Failed to fetch concurrents: ${response.body}');
      }
    } catch (e) {
      print('Error fetching concurrents: $e');
    }
  }

  void _filterProductsByConcurrent() {
    setState(() {
      if (selectedConcurrentId == null) {
        filteredProduits = produits; // Show all products if no filter is applied
      } else {
        filteredProduits = produits.where((product) {
          return product['concurrentId'] == selectedConcurrentId;
        }).toList();
      }
    });
  }

  Future<void> addProduit() async {
    if (_formKey.currentState!.validate()) {
      // Validate concurrent selection
      if (selectedConcurrentForAdd == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner un concurrent.')),
        );
        return;
      }

      // Validate price and name
      if (nameController.text.isEmpty || priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tous les champs sont obligatoires.')),
        );
        return;
      }

      final url = Uri.parse('$baseUrl/concurent/$selectedConcurrentForAdd/produits'); // Use the new endpoint
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
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
            'prix': double.tryParse(priceController.text) ?? 0.0, // Safely parse the price
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          await _fetchProduits(); // Refresh the products list
          nameController.clear();
          priceController.clear();
          selectedConcurrentForAdd = null; // Reset the selection
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit ajouté avec succès.')),
          );
        } else {
          print('Failed to add produit: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'ajout du produit.')),
          );
        }
      } catch (e) {
        print('Error adding produit: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du produit.')),
        );
      }
    }
  }

  Future<void> deleteProduit(String id) async {
    final url = Uri.parse('$baseUrl/produit/deleteProduit/$id');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
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
        _fetchProduits();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit supprimé avec succès')),
        );
      } else {
        print('Failed to delete produit: ${response.body}');
      }
    } catch (e) {
      print('Error deleting produit: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Produits'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedConcurrentId,
            hint: Text('Choisir un Concurrent'),
            onChanged: (newValue) {
              setState(() {
                selectedConcurrentId = newValue;
                _filterProductsByConcurrent();
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: null, // Use `null` to represent the "All" option
                child: Text('Tous', style: TextStyle(color: Colors.black)), // Label for "All"
              ),
              ...concurrents.map((concurrent) {
                return DropdownMenuItem<String>(
                  value: concurrent['id'],
                  child: Text(concurrent['nom']),
                );
              }).toList(),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProduits.length,
              itemBuilder: (context, index) {
                final produit = filteredProduits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0), // Similar spacing
                  elevation: 8, // Shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  color: Colors.white, // Background color
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0), // Padding inside the box
                    title: Text(
                      produit['nom'], // Product name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500, // Bold font
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${produit['prix']} Dinars', // Product price
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Concurrent: ${produit['concurrentNom']}', // Associated concurrent
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), // Delete icon
                      onPressed: () => deleteProduit(produit['id']), // Delete action
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ajouter un Produit',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          DropdownButton<String>(
                            value: selectedConcurrentForAdd,
                            hint: Text(
                              'Choisir un Concurrent',
                              style: TextStyle(color: Colors.white),
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                selectedConcurrentForAdd = newValue;
                              });
                            },
                            items: concurrents.map((concurrent) {
                              return DropdownMenuItem<String>(
                                value: concurrent['id'],
                                child: Text(
                                  concurrent['nom'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            isExpanded: true,
                            dropdownColor: Colors.grey[900],
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom du produit',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nom.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Prix',
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un prix.';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Veuillez entrer un prix valide.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Annuler', style: TextStyle(
                                  color: Colors.white
                                ),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedConcurrentForAdd == null) {
                          // Validate if a concurrent is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Veuillez sélectionner un concurrent.'),
                            ),
                          );
                          return;
                        }
                        if (nameController.text.isEmpty || priceController.text.isEmpty) {
                          // Validate if required fields are filled
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tous les champs sont obligatoires.'),
                            ),
                          );
                          return;
                        }
                        addProduit(); // Call the function to add the product
                      },
                      child: Text(
                        'Ajouter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
        backgroundColor: Colors.red,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
