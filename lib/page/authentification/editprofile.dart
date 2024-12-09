import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les réponses JSON
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/side_menu.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});


  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  final TextEditingController nameController =
  TextEditingController(text: "");
  final TextEditingController emailController =
  TextEditingController(text: "");

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  XFile? _profileImage;

  String baseUrl = "http://192.168.137.35:3000";

  Future<bool> _updateProfile(String name, String email, XFile? image) async {
    final url = Uri.parse(baseUrl + '/user/edit-profile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('Erreur : Aucun token trouvé. Redirection vers la page de connexion.');
      Navigator.pushReplacementNamed(context, '/');
      return false;
    }

    try {
      print('Préparation de la requête...');
      final request = http.MultipartRequest('PATCH', url);

      // Ajout du token
      request.headers['Authorization'] = 'Bearer $token';
      print('Token ajouté : $token');

      // Ajout des champs texte
      request.fields['name'] = name;
      print('Nom ajouté : $name');
      request.fields['email'] = email;
      print('Email ajouté : $email');

      // Ajout de l'image (si elle existe)
      if (image != null) {
        print('Tentative d\'ajout de l\'image...');
        final file = File(image.path);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              file.path,
            ),
          );
          print('Image ajoutée : ${image.path}');
        } else {
          print('Erreur : Le fichier image n\'existe pas.');
        }
      } else {
        print('Aucune image à ajouter.');
      }

      // Envoi de la requête
      print('Envoi de la requête...');
      final response = await request.send();

      print('Statut HTTP : ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Mise à jour réussie.');
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Erreur lors de la mise à jour : ${response.statusCode}, Détails : $responseBody');
        return false;
      }
    } catch (e) {
      print('Exception lors de la mise à jour : $e');
      return false;
    }
  }

  Future<bool> _changePassword(String newPassword) async {
    final url = Uri.parse(baseUrl + '/user/change-password');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('Aucun token trouvé. Redirection vers la page de connexion.');
      Navigator.pushReplacementNamed(context, '/');
      return false;
    }

    try {
      // Log the request
      print('URL: $url');
      print('Token: $token');
      print('Request Body: {"newPassword": "$newPassword", "confirmPassword": "$newPassword"}');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'newPassword': newPassword, 'confirmPassword': newPassword}),
      );

      // Log the response
      print('HTTP Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Mot de passe changé avec succès.');
        return true;
      } else if (response.statusCode == 401) {
        print('Token expiré ou non valide. Redirection...');
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      } else {
        print('Erreur lors du changement de mot de passe : ${response.statusCode}');
        print('Détails : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau lors du changement de mot de passe : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau. Veuillez réessayer.')),
      );
      return false;
    }
  }

  Future<void> _fetchUserData() async {
    final url = Uri.parse(baseUrl + '/user/getProfile');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print('Aucun token trouvé, redirection vers la page de connexion');
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Ajoute le token d'accès
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          if (data['image'] != null) {
            _profileImage = XFile(data['image']); // Charger l'image depuis l'URL
          }
        });
      } else if (response.statusCode == 401) {
        print('Token expiré ou non valide');
        Navigator.pushReplacementNamed(context, '/');
      } else {
        print('Erreur de récupération des données utilisateur : ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau lors de la récupération des données utilisateur : $e');
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');

    // Optionally show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have logged out successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            'Edit Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFFD42027),
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture Section
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _showImagePickerDialog(context),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFD42027),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Form Section
              Stack(
                children: [
                  AbsorbPointer(
                    absorbing: true,
                    // Prevent interaction with the TextFormField
                    child: TextFormField(
                      controller: nameController,
                      readOnly: true, // Prevent text editing
                      decoration: InputDecoration(
                        labelText: "Name",
                        prefixIcon: const Icon(
                            Icons.person, color: Colors.grey),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFD42027)),
                      onPressed: () =>
                          _showEditNameDialog(
                              context), // Only this button remains clickable
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Do nothing to block taps on the TextField
                },
                child: AbsorbPointer(
                  absorbing: true,
                  // Prevents interaction with the TextFormField
                  child: TextFormField(
                    controller: emailController,
                    readOnly: true, // Makes the field non-editable
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(
                        Icons.verified_outlined,
                        color: Colors.green, // Keep the verified icon
                      ),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Debugging inputs before making the request
              print('Nom actuel : ${nameController.text.trim()}');
              print('Email actuel : ${emailController.text.trim()}');
              print('Image actuelle : ${_profileImage?.path ?? 'Pas d\'image sélectionnée'}');

              // Call _updateProfile with parameters
              final success = await _updateProfile(
                nameController.text.trim(), // Nom
                emailController.text.trim(), // Email
                _profileImage, // Image (peut être null)
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour avec succès')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de la mise à jour')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
          ,

              const SizedBox(height: 30),
              // Save Button
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:  Colors.black.withOpacity(0.7), // Red background
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      // Shadow for box effect
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _utilityButton(
                      icon: Icons.lock,
                      label: 'Changer le Mot de Passe',
                      onTap: () => _showChangePasswordDialog(context),
                      labelColor: Colors.white,
                      // White text
                      iconColor: Colors.white, // White icon
                    ),
                    const Divider(color: Colors.white54), // White divider
                    _utilityButton(
                      icon: Icons.info,
                      label: 'À Propos',
                      onTap: () {},
                      labelColor: Colors.white,
                      iconColor: Colors.white,
                    ),
                    const Divider(color: Colors.white54), // White divider
                    _utilityButton(
                      icon: Icons.logout,
                      label: 'Se Déconnecter',
                      onTap: () {
                        _logout(context);
                      },
                      labelColor: Colors.white,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Centered Bottom Sheet for Changing Password
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Changer le Mot de Passe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Nouveau mot de passe
                TextField(
                  controller: newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Nouveau Mot de Passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Confirmation du mot de passe
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le Mot de Passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Color(0xFFD42027)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Vérifie que les mots de passe correspondent
                        if (newPasswordController.text.trim() !=
                            confirmPasswordController.text.trim()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Les mots de passe ne correspondent pas'),
                            ),
                          );
                          return;
                        }

                        final newPassword = newPasswordController.text.trim();

                        // Vérifie que le mot de passe n'est pas vide
                        if (newPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Le mot de passe ne peut pas être vide'),
                            ),
                          );
                          return;
                        }

                        final success = await _changePassword(newPassword);

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Erreur lors de la mise à jour')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD42027),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Confirmer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Centered Bottom Sheet for Editing Name
  // Modifier le nom
  void _showEditNameDialog(BuildContext context) {
    final TextEditingController editNameController =
    TextEditingController(text: nameController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le Nom"),
          content: TextField(
            controller: editNameController,
            decoration: const InputDecoration(
              labelText: "Nom complet",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = editNameController.text.trim();
                if (newName.isNotEmpty) {
                  final success = await _updateProfile(newName, emailController.text, _profileImage);
                  if (success) {
                    setState(() {
                      nameController.text = newName;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nom mis à jour avec succès')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la mise à jour')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom ne peut pas être vide')),
                  );
                }
              },
              style:
              ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD42027)),
              child: const Text('Confirmer',style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  // Utility Button Widget
  Widget _utilityButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color labelColor = Colors.black, // Default label color
    Color iconColor = Colors.black, // Default icon color
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:double.infinity,
        height: 42, // Matches the height of TextFormField
        padding: const EdgeInsets.symmetric(horizontal: 16), // Adds spacing
        alignment: Alignment.centerLeft, // Ensures content aligns properly
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24), // Icon size matches TextFormField
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 16, // Font size consistent with TextFormField
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Image Picker Dialog
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFD42027)),
                title: const Text("Take Photo"),
                onTap: () async {
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedImage != null) {
                    setState(() {
                      _profileImage = pickedImage;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                    Icons.photo_library, color: Color(0xFFD42027)),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final pickedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedImage != null) {
                    setState(() {
                      _profileImage = pickedImage;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );


    // Show Edit Name Dialog

  }
}