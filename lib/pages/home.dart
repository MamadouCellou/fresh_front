import 'package:fresh_front/pages/compartiments.dart';
import 'package:fresh_front/pages/dashboard.dart';
import 'package:fresh_front/pages/produits.dart';
import 'package:fresh_front/pages/profile.dart';
import 'package:fresh_front/widget/text_field_search.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    PageProduits(),
    PageCompartiment(),
    ProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Row(
            children: [
              IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  // Action pour l'icône de localisation
                },
              ),
              SizedBox(width: 3), // Espace entre l'icône et le texte
              Text(
                'Paris', // Nom de la ville
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    // Action pour l'icône de notification
                  },
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green, // Couleur du badge
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16), // Espace entre les icônes, si nécessaire
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acccueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'Compartiments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
