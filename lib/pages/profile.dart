import 'package:fresh_front/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = false;

  bool isProfile = false;
  bool isMandaFreshSelected = false;
  bool showAccounts = false;

String selectedAccount =
                "Compte 1";
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
          SizedBox(height: 20),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            trailing: Icon(Icons.arrow_right),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Aide ou Support'),
            onTap: () {
              // Navigate to support page
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Partager l\'application'),
            onTap: () {
              // Share app functionality
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Déconnexion'),
            trailing: Icon(Icons.arrow_right),
            onTap: _showDeconnexionBottomSheet,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Personnalisation du Profil'),
            onTap: () {
              // Navigate to profile customization
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.brightness_4),
            title: Text('Mode Sombre/Clair'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (val) {
                setState(() {
                  isDarkMode = val;
                });
                // Toggle dark/light mode
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to terms and conditions page
            },
            child: Column(
              children: [
                Text('Conditions d\'utilisation',
                    style: TextStyle(decoration: TextDecoration.underline)),
                Text(
                  'Politiques de confidentialité',
                  style: TextStyle(decoration: TextDecoration.underline),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeconnexionBottomSheet() {
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
                                backgroundColor: const Color.fromARGB(255, 240, 158, 158), // Utilisez 'backgroundColor' au lieu de 'primary'
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                              ),
                              child: Text(
                                "Se déconnecter",
                                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
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
}
