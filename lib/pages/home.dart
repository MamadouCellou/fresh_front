import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fresh_front/pages/affiche_produit.dart';
import 'package:fresh_front/pages/dashboard.dart';
import 'package:fresh_front/pages/gps.dart';
import 'package:fresh_front/pages/login.dart';
import 'package:fresh_front/pages/page_chaud_product.dart';
import 'package:fresh_front/pages/page_froid_product.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/pages/reclage_select_compartiment.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  loc.LocationData? _currentLocation;
  String _currentAddress = "Chargement...";
  final loc.Location _location = loc.Location(); // Instance de Location
  late StreamSubscription<loc.LocationData> _locationSubscription;

  String? userEmail;
  String? userDeviceId;
  String userFirstName = "";
  String userLastName = "";
  String userImage = "";

  @override
  void initState() {
    super.initState();

    // Récupérer les arguments envoyés lors de la navigation
    userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Email non disponible';;

    // Charger les informations de l'utilisateur depuis Firebase
    _loadUserData();

    // Initialiser les services de localisation
    _requestLocationPermission();
    _locationSubscription =
        _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
          _getAddressFromLatLng();
        });
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription
        .cancel(); // Annule l'abonnement lorsque le widget est détruit
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    _getAddressFromLatLng();
  }

  Future<void> _getAddressFromLatLng() async {
    if (_currentLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );

        Placemark place = placemarks[0];

        if (mounted) {
          setState(() {
            _currentAddress = "${place.locality}";
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _loadUserData() async {
    if (userEmail != null) {
      // Récupérer les détails de l'utilisateur depuis Firestore
      var snapshot = await FirebaseFirestore.instance
          .collection('Utilisateurs')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          userFirstName = snapshot.docs.first['prenom'];
          userLastName = snapshot.docs.first['nom'];
          userImage = snapshot.docs.first['image'];
        });
      }
    }
  }

  bool isDarkMode = false;
  bool isProfile = false;
  bool isMandaFreshSelected = false;
  bool showAccounts = false;
  String selectedAccount = "Compte 1";

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
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu), // Icône du menu
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // Ouvre le Drawer
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Get.to(MapPage());
          },
          child: Row(
            children: [
              Text(
                _currentAddress,
                style: TextStyle(fontSize: 18),
              ),
              Icon(
                Icons.location_on,
                size: 18,
              )
            ],
          ),
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
                right: 10,
                top: 8,
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
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : AssetImage('assets/images/default_avatar.png')
                                as ImageProvider,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$userFirstName $userLastName',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        userEmail ?? 'email inconnu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Divider(),
                      paramItem(
                          icon: Icons.settings, nom: "Paramètres", plus: true),
                      paramItem(
                          icon: Icons.menu_book,
                          nom: "Guide de conservation",
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
                              Text(
                                'Sélectionnez un compte',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        if (!showAccounts)
                          Row(
                            children: [
                              Text(
                                'Déconnexion',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Get.off(Login());
                                },
                                child: Text(
                                  'Déconnecter',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            ],
                          ),
                        SizedBox(height: 16),
                        if (!showAccounts)
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/images/default_avatar.png'),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ListTile(
                                  title: Text(selectedAccount),
                                  subtitle: Text('Gestionnaire'),
                                  onTap: _toggleView,
                                  trailing: Icon(Icons.arrow_drop_down),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text('Gérer'),
                              ),
                            ],
                          ),
                        if (showAccounts) ...[
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/default_avatar.png'),
                            ),
                            title: Text('Compte 1'),
                            subtitle: Text('gestionnaire'),
                            onTap: () {
                              _selectAccount('Compte 1');
                            },
                            trailing: selectedAccount == 'Compte 1'
                                ? Icon(Icons.check, color: Colors.blue)
                                : null,
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/default_avatar.png'),
                            ),
                            title: Text('Compte 2'),
                            subtitle: Text('gestionnaire'),
                            onTap: () {
                              _selectAccount('Compte 2');
                            },
                            trailing: selectedAccount == 'Compte 2'
                                ? Icon(Icons.check, color: Colors.blue)
                                : null,
                          ),
                        ]
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget paramItem(
      {required IconData icon, required String nom, bool plus = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(nom),
      trailing: plus ? Icon(Icons.arrow_right) : null,
    );
  }
}
