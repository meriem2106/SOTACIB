import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;


class NouvelleVisite extends StatefulWidget {
  @override
  _NouvelleVisiteState createState() => _NouvelleVisiteState();
}

class _NouvelleVisiteState extends State<NouvelleVisite> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController responsableController = TextEditingController();
  final TextEditingController reclamationController = TextEditingController();
  final TextEditingController observationController = TextEditingController();

  final List<String> cimenterieOptions = [
    'SK',
    'SCB',
    'CAT',
    'CC',
    'CJO',
    'SCE',
    'SCG',
    'CIOK',
  ];
  final List<String> productOptions = [
    'CEM I 42,5',
    'CEM II 32,5',
    'CEM I 42,5 SR-3',
    'CHAUX',
  ];

  final List<Map<String, dynamic>> cimenterieData = [];

  // Add a new cimenterie
  void addCimenterie() {
    setState(() {
      cimenterieData.add({'cimenterie': null, 'products': []});
    });
  }

  // Add a new product under a specific cimenterie
  void addProduct(int cimenterieIndex) {
    setState(() {
      cimenterieData[cimenterieIndex]['products']
          .add({'product': null, 'price': ''});
    });
  }

  // Submit the form
  Future<void> submitForm() async {
    final url = Uri.parse("http://192.168.137.35:3000/visite/ajouterVisite"); // Update with your backend URL

    // Prepare the data
    final requestBody = {
      "date": dateController.text,
      "responsable": responsableController.text,
      "observation": observationController.text,
      "reclamation": reclamationController.text,
      "cimenteries": cimenterieData
          .map((c) => {
        "cimenterie": c['cimenterie'],
        "produits": c['products']
            .map((p) => {"produit": p['product'], "prix": p['price']})
            .toList(),
      })
          .toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text(responseData['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Failed to submit the form");
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to submit the form. Error: $error"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nouvelle Visite"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: "Date",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today, color: Colors.red),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateController.text =
                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  });
                }
              },
            ),
            SizedBox(height: 16.0),

            // Responsable Name
            TextField(
              controller: responsableController,
              decoration: InputDecoration(
                labelText: "Responsable",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.red),
              ),
            ),
            SizedBox(height: 16.0),

            // Cimenterie, Products, and Prices
            Text(
              "Cimenterie, Produits, et Prix",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            SizedBox(height: 8.0),

            // List of Cimenteries
            ...cimenterieData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> cimenterie = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cimenterie Dropdown
                  DropdownButtonFormField<String>(
                    value: cimenterie['cimenterie'],
                    decoration: InputDecoration(
                      labelText: "Cimenterie",
                      border: OutlineInputBorder(),
                    ),
                    items: cimenterieOptions
                        .map((option) => DropdownMenuItem(
                        value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        cimenterie['cimenterie'] = value;
                      });
                    },
                  ),
                  SizedBox(height: 8.0),

                  // Products and Prices
                  ...cimenterie['products'].asMap().entries.map((productEntry) {
                    int productIndex = productEntry.key;
                    Map<String, String?> product = productEntry.value;

                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: product['product'],
                            decoration: InputDecoration(
                              labelText: "Produit",
                              border: OutlineInputBorder(),
                            ),
                            items: productOptions
                                .map((option) => DropdownMenuItem(
                                value: option, child: Text(option)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                product['product'] = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Prix",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                product['price'] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                  // Add Product Button
                  TextButton.icon(
                    onPressed: () => addProduct(index),
                    icon: Icon(Icons.add, color: Colors.red),
                    label: Text("Ajouter Produit"),
                  ),
                ],
              );
            }).toList(),

            // Add Cimenterie Button
            ElevatedButton(
              onPressed: addCimenterie,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Ajouter Cimenterie"),
            ),
            SizedBox(height: 16.0),

            // Observation
            TextField(
              controller: observationController,
              decoration: InputDecoration(
                labelText: "Observation",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),

            // Reclamation
            TextField(
              controller: reclamationController,
              decoration: InputDecoration(
                labelText: "Réclamation",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),

            // Submit and Cancel Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Ajouter Visite"),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}