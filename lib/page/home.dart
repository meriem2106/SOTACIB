import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // For coordinates
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/side_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng? currentPosition;
  LatLng? givenAddressPosition;
  String selectedGouvernorat = 'All';
  String? selectedDelegation;
  List<Marker> clientMarkers = [];
  Marker? staticAddressMarker;
  String bottomSheetSelectedGouvernorat = 'All';
  String? bottomSheetSelectedDelegation;

  String? clientType; // To store selected client type

  TextEditingController clientNameController = TextEditingController();
  TextEditingController responsibleNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  final Map<String, List<String>> gouvernoratDelegations = {
    "All": ["All"],
    "Ariana": ["All", "Ariana Ville", "Ettadhamen", "Kalâat Andalous", "La Soukra", "M'nihla", "Raoued", "Sidi Thabet"],
    "Béja": ["All", "Amdoun", "Béja Nord", "Béja Sud", "Goubellat", "Medjez El Bab", "Nefza", "Teboursouk", "Testour", "Thibar"],
  };

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _getGivenAddressPosition(
        'نهج نيوتن, Zone Industrielle Chotrana II, النخيلات, معتمدية رواد, ولاية أريانة, 2088, تونس');
    _getGivenAddressPosition1('676 Avenue Jaafer Sidi Amor, Ariana');
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        currentPosition = LatLng(33.8869, 9.5375); // Default to Tunisia
      });
    }
  }

  Future<void> _getGivenAddressPosition(String address) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=$address&format=json&addressdetails=1&limit=1';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          setState(() {
            givenAddressPosition = LatLng(lat, lon);
          });
        }
      } else {
        print('Failed to fetch address position: ${response.body}');
      }
    } catch (e) {
      print('Error fetching address position: $e');
    }
  }

  Future<void> _getGivenAddressPosition1(String address) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/search?q=$address&format=json&addressdetails=1&limit=1';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          setState(() {
            givenAddressPosition = LatLng(lat, lon);
          });
        }
      } else {
        print('Failed to fetch address position: ${response.body}');
      }
    } catch (e) {
      print('Error fetching address position: $e');
    }
  }

  Future<void> _fetchAddress() async {
    if (currentPosition == null) {
      await _determinePosition();
    }
    if (currentPosition != null) {
      try {
        final response = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            addressController.text = data['display_name'] ?? 'Unknown Address';
          });
        } else {
          print('Failed to fetch address: ${response.body}');
        }
      } catch (e) {
        print('Error fetching address: $e');
      }
    }
  }

  Future<void> addClient() async {
    final String apiUrl = 'http://192.168.137.35:3000/client/ajouterClient';

    if (clientNameController.text.isEmpty ||
        responsibleNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        bottomSheetSelectedGouvernorat == 'All' ||
        bottomSheetSelectedDelegation == null ||
        clientType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires et sélectionner un type de client.')),
      );
      return;
    }

    try {
      final payload = {
        'responsable': responsibleNameController.text,
        'clientNom': clientNameController.text,
        'clientType': clientType,
        'email': emailController.text,
        'telephone': int.tryParse(phoneNumberController.text),
        'address': addressController.text,
        'gouvernoratNom': bottomSheetSelectedGouvernorat,
        'delegationNom': bottomSheetSelectedDelegation,
        'produits': [], // Leave empty for now
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client ajouté avec succès.')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to add client: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout du client.')),
        );
      }
    } catch (e) {
      print('Error adding client: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du client.')),
      );
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.black,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter Client',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Gouvernorat Dropdown
                      Text(
                        'Gouvernorat',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      DropdownButton<String>(
                        value: bottomSheetSelectedGouvernorat,
                        dropdownColor: Colors.black,
                        items: gouvernoratDelegations.keys.map((gouvernorat) {
                          return DropdownMenuItem(
                            value: gouvernorat,
                            child: Text(
                              gouvernorat,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setBottomSheetState(() {
                            bottomSheetSelectedGouvernorat = value!;
                            bottomSheetSelectedDelegation =
                            gouvernoratDelegations[value]![0];
                          });
                        },
                        isExpanded: true,
                        underline: Container(),
                      ),
                      SizedBox(height: 15),

                      // Delegation Dropdown
                      Text(
                        'Délégation',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      DropdownButton<String>(
                        value: bottomSheetSelectedDelegation,
                        dropdownColor: Colors.black,
                        items: (gouvernoratDelegations[bottomSheetSelectedGouvernorat] ?? [])
                            .map((delegation) {
                          return DropdownMenuItem(
                            value: delegation,
                            child: Text(
                              delegation,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setBottomSheetState(() {
                            bottomSheetSelectedDelegation = value!;
                          });
                        },
                        isExpanded: true,
                        underline: Container(),
                      ),
                      SizedBox(height: 15),

                      // Client Type Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute evenly
                        children: [
                          Radio<String>(
                            value: 'G',
                            groupValue: clientType,
                            onChanged: (value) {
                              setBottomSheetState(() {
                                clientType = value;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          Text(
                            'G',
                            style: TextStyle(color: Colors.white),
                          ),
                          Radio<String>(
                            value: 'D',
                            groupValue: clientType,
                            onChanged: (value) {
                              setBottomSheetState(() {
                                clientType = value;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          Text(
                            'D',
                            style: TextStyle(color: Colors.white),
                          ),
                          Radio<String>(
                            value: 'NC',
                            groupValue: clientType,
                            onChanged: (value) {
                              setBottomSheetState(() {
                                clientType = value;
                              });
                            },
                            activeColor: Colors.red,
                          ),
                          Text(
                            'NC',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Input Fields
                      TextField(
                        controller: clientNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du Client',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: responsibleNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom du Responsable',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),

                      // Address with Location Button
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: 'Adresse',
                                labelStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.location_on, color: Colors.white),
                            onPressed: _fetchAddress,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      Center(
                        child: ElevatedButton(
                          onPressed: addClient,
                          child: Text(
                            'Ajouter Client',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFD42027),
        centerTitle: true,
      ),
      drawer: SideMenu(),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : mapContainer(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFD42027),
      ),
    );
  }

  Widget mapContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD42027), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FlutterMap(
        options: MapOptions(
          center: currentPosition ?? LatLng(33.8869, 9.5375), // Default to Tunisia
          zoom: 11,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.soticab_app',
          ),
          MarkerLayer(
            markers: [
              if (currentPosition != null)
                Marker(
                  point: currentPosition!,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.my_location,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
              if (givenAddressPosition != null)
                Marker(
                  point: givenAddressPosition!,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_pin,
                    size: 60,
                    color: Color(0xFFD42027),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  TileLayer openStreetMapTileLayer = TileLayer(
    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    userAgentPackageName: 'com.example.soticab_app',
  );
}
