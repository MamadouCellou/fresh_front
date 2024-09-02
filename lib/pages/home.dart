import 'package:fresh_front/pages/dashboard.dart';
import 'package:fresh_front/pages/page_chaud_product.dart';
import 'package:fresh_front/pages/page_froid_product.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/pages/reclage_select_compartiment.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    PageFroidProduct(),
    PageChaudProduct(),
    ReclageSelectCompartiment()
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
                icon: Icon(Icons.location_on,),
                onPressed: () {
                  // Action pour l'icône de localisation
                },
              ),// Espace entre l'icône et le texte
              
            ],
          ),
          title: Text("Paris"),
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
            SizedBox(width: 6), // Espace entre les icônes, si nécessaire
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
            icon: Icon(Icons.ac_unit),
            label: 'C. Froid',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'C. Chaud',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.tune),
            label: 'Reglage',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
