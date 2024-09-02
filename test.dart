/* import 'package:fresh_front/pages/affiche_produit.dart';
import 'package:fresh_front/pages/compartiments.dart';
import 'package:fresh_front/pages/dashboard.dart';
import 'package:fresh_front/pages/login.dart';
import 'package:fresh_front/pages/produits.dart';
import 'package:fresh_front/pages/profile.dart';
import 'package:fresh_front/widget/text_field_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  bool isDarkMode = false;

  bool isProfile = false;
  bool isMandaFreshSelected = false;
  bool showAccounts = false;

  String selectedAccount = "Compte 1";

  static List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    // PageProduits(),
    // PageCompartiment(),
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
        title: Text("Acceuil"),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/cellou.jpg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Mamadou Cellou Diallo',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'cellou@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Divider(),
                      paramItem(
                          icon: Icons.settings, nom: "Paramètres", plus: true),
                      // Divider(color: Colors.black.withOpacity(0.1),),
                      paramItem(
                          icon: Icons.menu_book,
                          nom: "Guide conservation",
                          plus: true),
                      paramItem(
                          icon: Icons.person,
                          nom: "Modifier profil",
                          plus: true),
                      paramItem(
                          icon: Icons.feedback, nom: "Aide & commentaires"),
                      paramItem(
                          icon: Icons.share, nom: "Partager l'application")
                    ],
                  ),
                  Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.brightness_4),
                        title: Text('Sombre/Clair'),
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (val) {
                            setState(() {
                              isDarkMode = val;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Déconnexion'),
                        trailing: Icon(Icons.arrow_right),
                        onTap: _showDeconnexionBottomSheet,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
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

  void _showDeconnexionBottomSheet() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void _toggleView() => setState(() => showAccounts = !showAccounts);
            void _selectAccount(String accountName) => setState(() {
                  selectedAccount = accountName;
                  showAccounts = false;
                });

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showAccounts)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: _toggleView,
                              ),
                              Expanded(
                                child: Text(
                                  "Changer de comptes",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            "Se déconnecter",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold),
                          ),
                        if (!showAccounts)
                          ListTile(
                            title: Text("Comptes MandaFresh",
                                style: TextStyle(fontSize: 18)),
                            subtitle: Text(
                              selectedAccount,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                            trailing: Icon(Icons.arrow_right),
                            onTap: _toggleView,
                          ),
                        if (!showAccounts)
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(Login());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255,
                                    240,
                                    158,
                                    158), // Utilisez 'backgroundColor' au lieu de 'primary'
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                              ),
                              child: Text(
                                "Se déconnecter",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (showAccounts)
                          Column(
                            children: ["Compte 1", "Compte 2"]
                                .map(
                                  (account) => ListTile(
                                    title: Text(account,
                                        style: TextStyle(fontSize: 18)),
                                    leading: Radio(
                                      value: account,
                                      groupValue: selectedAccount,
                                      onChanged: (String? value) =>
                                          _selectAccount(value!),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget paramItem(
      {required IconData icon,
      required String nom,
      bool plus = false,
      dynamic go = AfficueProduit.new}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(nom),
      trailing: plus ? Icon(Icons.arrow_right) : null,
      onTap: () {
        Navigator.pop(context);
        plus ? Get.to((go)) : null;
      },
    );
  }
} */