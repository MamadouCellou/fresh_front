import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/pages/home.dart';
import 'package:fresh_front/pages/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import Firebase Auth

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _passwordVisible = false;
  bool _isLoading = false; // Ajout d'une variable pour gérer le chargement

  Future<void> _loginUser() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState?.fields['email']?.value;
      final password = _formKey.currentState?.fields['password']?.value;

      setState(() {
        _isLoading = true; // Afficher le loader
      });

      try {
        // Connexion de l'utilisateur avec Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Rediriger vers la page d'accueil après la connexion réussie
        String? id_dispo = await fetchAndStoreUserDeviceId(email);

        Get.to(HomePage());

        showCustomSnackbar(
          message: "Connexion réussie!",
          type: "success",
        );
      } catch (e) {
        if (e.toString().contains(
            "The supplied auth credential is incorrect, malformed or has expired")) {
          showCustomSnackbar(
            message: "Emeil ou mot de passe incorrects",
            type: "error",
            colorText: Colors.white,
          );
        } else {
          showCustomSnackbar(
            message: "Erreur lors de la connexion",
            type: "error",
            colorText: Colors.white,
          );
        }
      } finally {
        setState(() {
          _isLoading = false; // Cacher le loader
        });
      }
    }
  }

  Future<String?> fetchAndStoreUserDeviceId(String email) async {
    String? deviceId;
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Users_dispo')
          .where('email_user', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        deviceId = snapshot.docs.first['id_dispo'];
      }
      return deviceId;
    } catch (e) {
      print(
          "Erreur lors de la récupération de l'identifiant du dispositif: $e");
    }
    return null;
  }

  Future<void> storeUserInfo(String email, String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('device_id', deviceId);

    print(prefs.getString('user_email'));
    print(prefs.getString('device_id'));
    print("restyf");
  }

  void showCustomSnackbar({
    required String message,
    required String type,
    Color colorText = Colors.black,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case 'success':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'error':
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue;
        icon = Icons.info;
    }

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorText),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      snackPosition: SnackPosition.TOP,
      borderRadius: 8,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 10),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "S'authentifier",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text("Hey bienvenue vous nous aviez manqué"),
                        ),
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: FormBuilderTextField(
                                  name: "email",
                                  validator: FormBuilderValidators.email(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.1),
                                    labelText: "Email",
                                    labelStyle: TextStyle(fontSize: 20),
                                    hintText: "Entrez votre email",
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: FormBuilderTextField(
                                  name: "password",
                                  validator: FormBuilderValidators.required(
                                      errorText: "Veuillez remplir ce champ"),
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.1),
                                    labelText: "Mot de passe",
                                    labelStyle: TextStyle(fontSize: 20),
                                    hintText: "Entrez votre mot de passe",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, right: 21, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Mot de passe oublié",
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue,
                                        color: Colors.blue),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 20, left: 20, right: 20, bottom: 20),
                                child: GFButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _loginUser, // Appel de la fonction _loginUser
                                  shape: GFButtonShape.pills,
                                  fullWidthButton: true,
                                  textColor: Colors.white,
                                  size: GFSize.LARGE,
                                  color: GFColors.PRIMARY,
                                  textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  text: _isLoading
                                      ? "Chargement..."
                                      : "Connexion",
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 0.5,
                                        child: ColoredBox(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Text("Ou connectez-vous avec"),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 0.5,
                                        child: ColoredBox(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 40, right: 40),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildSocial(
                                            image: Image.asset(
                                                "assets/images/apple.png")),
                                        buildSocial(
                                            image: Image.asset(
                                                "assets/images/google.png")),
                                        buildSocial(
                                            image: Image.asset(
                                                "assets/images/facebook.png"))
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Pas encore de compte ?"),
                              GestureDetector(
                                onTap: () {
                                  Get.to(Signup());
                                },
                                child: Text(
                                  "S'inscrire",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.blue),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Center(
                child:
                    CircularProgressIndicator(), // Loader au centre de l'écran
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSocial({required Image image}) {
    return Container(
      height: 70,
      width: 70,
      padding: EdgeInsets.all(20),
      child: image,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }
}
