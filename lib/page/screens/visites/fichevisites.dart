import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FicheVisitesScreen extends StatefulWidget {
  const FicheVisitesScreen({super.key});

  @override
  _FicheVisitesScreenState createState() => _FicheVisitesScreenState();
}

class _FicheVisitesScreenState extends State<FicheVisitesScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String selectedClient = "Tous les clients";
  List<String> clients = ["Tous les clients"]; // Initialize with default option
  List<Map<String, dynamic>> _visites = [];
  List<Map<String, dynamic>> _filteredVisites = [];

  final String fetchVisitesUrl = 'http://192.168.137.35:3000/visite/fetchVisites';
  final String fetchClientsUrl = 'http://192.168.137.35:3000/client/fetchClient'; // Adjust if needed

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch visits
      final visitesResponse = await http.get(Uri.parse(fetchVisitesUrl));
      print("Visites Response Status: ${visitesResponse.statusCode}");
      print("Visites Response Body: ${visitesResponse.body}");

      // Fetch clients without unnecessary parameters
      final clientsResponse = await http.get(Uri.parse(fetchClientsUrl));
      print("Clients Response Status: ${clientsResponse.statusCode}");
      print("Clients Response Body: ${clientsResponse.body}");

      if (visitesResponse.statusCode == 200 && clientsResponse.statusCode == 200) {
        setState(() {
          // Decode visits and clients
          _visites = List<Map<String, dynamic>>.from(json.decode(visitesResponse.body));
          clients.addAll(List<String>.from(json.decode(clientsResponse.body).map((client) => client['nom'])));
          _filteredVisites = _visites; // Initialize filtered visits with all visits
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      controller.text = "${pickedDate.toLocal()}".split(' ')[0];
    }
  }

  void _filterVisites() {
    String startDate = _startDateController.text;
    String endDate = _endDateController.text;

    setState(() {
      _filteredVisites = _visites.where((visite) {
        bool matchesDateRange = true;
        if (startDate.isNotEmpty) {
          matchesDateRange &= visite["date"].compareTo(startDate) >= 0;
        }
        if (endDate.isNotEmpty) {
          matchesDateRange &= visite["date"].compareTo(endDate) <= 0;
        }
        bool matchesClient = selectedClient == "Tous les clients" ||
            visite["client"] == selectedClient;
        return matchesDateRange && matchesClient;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD42027),
        title: const Text('Fiche Visites', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, _startDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          hintText: 'Date de début',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, _endDateController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          hintText: 'Date de fin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClient,
                    items: clients
                        .map((client) => DropdownMenuItem(
                      value: client,
                      child: Text(client),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClient = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Client',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _filterVisites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('Filtrer', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _filteredVisites.length,
                itemBuilder: (context, index) {
                  final visite = _filteredVisites[index];
                  return Card(
                    color: const Color.fromARGB(255, 184, 182, 182),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${visite["date"]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Client: ${visite["client"] ?? "Non spécifié"}'),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              'Observations: ${visite["observation"] ?? "N/A"}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
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
          Navigator.pushNamed(context, '/addVisite');
        },
        backgroundColor: const Color(0xFFD42027),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
