import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../authentification/editprofile.dart';
import '../clients.dart';
import '../home.dart';
import '../screens/visites/fichevisites.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? userRole; // Store the user's role

  final   String baseUrl = "http://192.168.137.35:3000";

  @override
  void initState() {
    super.initState();
    _fetchUserRole(); // Fetch user role when the menu is initialized
  }

  Future<void> _fetchUserRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        print("No token found. Redirecting to login...");
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/getProfile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          userRole = userData['role'];
        });
      } else if (response.statusCode == 401) {
        print("Unauthorized. Redirecting to login...");
        Navigator.pushReplacementNamed(context, '/');
      } else {
        print("Failed to fetch user role: ${response.body}");
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // DrawerHeader with logo
          DrawerHeader(
            child: Image.asset(
              "assets/logo.png",
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          // List of items in the drawer
          Expanded(
            child: ListView(
              children: [
                DrawerListTile(
                  title: "Carte Géographique",
                  icon: Icons.map,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                _smallDivider(),
                DrawerListTile(
                  title: "Visites",
                  icon: Icons.directions_walk,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FicheVisitesScreen()),
                    );
                  },
                ),
                _smallDivider(),
                DrawerListTile(
                  title: "Nos Clients",
                  icon: Icons.person_4_rounded,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientScreen()),
                    );
                  },
                ),
                _smallDivider(),
                // Conditionally display "Produits" based on role

                if (userRole == 'admin') ...[
                  DrawerListTile(
                    title: "Produits",
                    icon: Icons.shopping_bag,
                    press: () {
                      Navigator.pushNamed(context, '/produits'); // Navigate to AddVisiteScreen
                    },
                  ),
                  _smallDivider(),
                  DrawerListTile(
                    title: "Utilisateurs",
                    icon: Icons.person,
                    press: () {
                        Navigator.pushNamed(context, '/addCommercial'); // Navigate to AddVisiteScreen
                      },
                  ),
                  _smallDivider(),
                  DrawerListTile(
                    title: "Concurrents",
                    icon: Icons.person_4_rounded,
                    press: () {
                      Navigator.pushNamed(context, '/addCimenterie'); // Navigate to AddVisiteScreen
                    },
                  ),
                  _smallDivider(),
                ],
                DrawerListTile(
                  title: "Statistiques",
                  icon: Icons.bar_chart,
                  press: () {Navigator.pushNamed(context, "/disponibilite");},
                ),
                _smallDivider(),
                DrawerListTile(
                  title: "Planification",
                  icon: Icons.calendar_today,
                  press: () {Navigator.pushNamed(context, "/planification");},
                ),
                _smallDivider(),
                DrawerListTile(
                  title: "Profile",
                  icon: Icons.person,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Logout button
          Container(
            color: const Color(0xFFD42027),
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                _logout(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: const Text(
                "Déconnexion",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vous vous êtes déconnecté avec succès!')),
    );
  }
}

Widget _smallDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 14.0),
    child: Divider(
      thickness: 1,
      height: 10,
      color: Color(0xFFbebebe),
    ),
  );
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 16.0,
      leading: Icon(
        icon,
        color: const Color(0xFFD42027),
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFFD42027)),
      ),
    );
  }
}
