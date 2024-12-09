import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/side_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClientScreen(),
    );
  }
}

class ClientScreen extends StatefulWidget {
  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  List<dynamic> clients = []; // Store fetched client data
  String searchQuery = '';
  String selectedGovernorate = '';
  String selectedDelegation = '';
  bool isLoading = false;

  final String apiUrl = 'http://192.168.137.35:3000/client/fetchClient'; // Backend URL

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  // Fetch clients from the backend
  Future<void> fetchClients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decode JSON response
        if (data.containsKey('client')) {
          setState(() {
            clients = data['client']; // Extract client data
          });
        } else {
          print('Response does not contain "client" key');
        }
      } else {
        print('Failed to fetch clients: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching clients: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete a client by ID
  Future<void> deleteClient(String id) async {
    final String deleteUrl = 'http://37.37.37.34:3000/client/$id'; // Backend delete URL
    try {
      final response = await http.delete(Uri.parse(deleteUrl));
      if (response.statusCode == 200) {
        setState(() {
          clients.removeWhere((client) => client['_id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client supprimé avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression du client')),
        );
      }
    } catch (e) {
      print('Error deleting client: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredClients = clients.where((client) {
      final matchesSearch = (client['clientNom'] ?? '')
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final matchesGovernorate = selectedGovernorate.isEmpty ||
          client['gouvernoratNom'] == selectedGovernorate;
      final matchesDelegation = selectedDelegation.isEmpty ||
          client['delegationNom'] == selectedDelegation;
      return matchesSearch && matchesGovernorate && matchesDelegation;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Nos Clients', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFD42027),
      ),
      drawer: SideMenu(),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des clients...',
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                    selectedGovernorate.isEmpty ? null : selectedGovernorate,
                    decoration: InputDecoration(labelText: 'Gouvernorat'),
                    items: ['Ariana', 'Tunis', 'Ben Arous'] // Example items
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGovernorate = value ?? '';
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value:
                    selectedDelegation.isEmpty ? null : selectedDelegation,
                    decoration: InputDecoration(labelText: 'Délégation'),
                    items: ['Ariana Ville', 'La Soukra'] // Example items
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDelegation = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.separated(
                itemCount: filteredClients.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFFD42027),
                        child: Text(
                          client['_id']?.toString().substring(0, 1) ??
                              'N/A',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        client['clientNom'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Responsable: ${client['responsable'] ?? 'N/A'}\n'
                            'Type: ${client['clientType'] ?? 'N/A'}\n'
                            'Gouvernorat: ${client['gouvernoratNom'] ?? 'N/A'}\n'
                            'Délégation: ${client['delegationNom'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteClient(client['_id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
