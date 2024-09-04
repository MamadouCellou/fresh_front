import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../constant/colors.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _deviceFormKey = GlobalKey<FormBuilderState>();
  final PageController _pageController = PageController();

  bool _passwordVisible = false;
  bool _mandaPasswordVisible = false;
  bool? checked = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String _selectedGenre = "";
  Color couleurApp = Color.fromRGBO(17, 186, 24, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildDevicePage(), // Page pour les identifiants du dispositif
            _buildUserSignupPage(), // Page pour l'inscription de l'utilisateur
          ],
        ),
      ),
    );
  }

  Widget _buildDevicePage() {
    // Page pour entrer les identifiants du dispositif
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100,bottom: 50),
              child: Text(
                "Informations de votre MandaFresh",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            FormBuilder(
              key: _deviceFormKey,
              child: Column(
                children: [
                  buildChamp(
                      name: "identifiant",
                      hintText: "Entrer l'identifiant du dispositif",
                      labelText: "Identifiant"),
                  buildChamp(
                      name: "motDePasseDispositif",
                      hintText: "Entrez le mot de passe",
                      labelText: "Mot de passe du MandaFresh",
                      obscureText: !_mandaPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mandaPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _mandaPasswordVisible = !_mandaPasswordVisible;
                          });
                        },
                      )),
                ],
              ),
            ),
            GFButton(
              onPressed: _verifyDeviceCredentials,
              shape: GFButtonShape.pills,
              fullWidthButton: true,
              textColor: Colors.white,
              size: GFSize.LARGE,
              color: GFColors.PRIMARY,
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              text: "Vérifier et continuer",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSignupPage() {
    // Page pour l'inscription de l'utilisateur
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 20, top: 20),
              child: Text(
                "Vos informations personnelles",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  buildChamp(
                      name: "nom",
                      hintText: "Entrer votre nom",
                      labelText: "Nom"),
                  buildChamp(
                      name: "prenom",
                      hintText: "Entrer votre prenom",
                      labelText: "Prenom"),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: FormBuilderDateTimePicker(
                      name: "dateNaissance",
                      validator: FormBuilderValidators.required(
                          errorText: "Veillez remplir ce champ"),
                      inputType: InputType.date,
                      format: DateFormat("dd/MM/yyyy"),
                      initialDate: DateTime.now(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                        labelText: "Date de naissance",
                        labelStyle: TextStyle(fontSize: 20),
                        hintText: "Sélectionnez votre date de naissance",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: couleurApp),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  buildChamp(
                      name: "profession",
                      hintText: "Entrer votre profession",
                      labelText: "Profession"),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                        labelText: 'Votre genre',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ['Homme', 'Femme']
                          .map((value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (newGenre) {
                        setState(() {
                          print("Avant : " + _selectedGenre);
                          _selectedGenre = newGenre!;
                          print("Après : " + _selectedGenre);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: FormBuilderTextField(
                      name: "email",
                      cursorColor: couleurApp,
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: couleurApp),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: FormBuilderTextField(
                      name: "password",
                      validator: FormBuilderValidators.required(
                          errorText: "Veillez remplir ce champ"),
                      cursorColor: couleurApp,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.1),
                        labelText: "Mot de passe",
                        labelStyle: TextStyle(
                          fontSize: 20,
                        ),
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: couleurApp),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  _imageFile != null
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            "Votre photo",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _showImageSourceBottomSheet,
                          child: Text('Sélectionner votre photo'),
                        ),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          height: 200,
                        )
                      : SizedBox(),
                ],
              ),
            ),
            FormBuilderCheckbox(
              name: 'accept_terms',
              initialValue: false,
              title: Text(
                "J'accepte les termes et conditions",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                  color: Colors.blue,
                ),
              ),
              validator: FormBuilderValidators.equal(
                true,
                errorText:
                    'Vous devez accepter les termes et conditions pour continuer.',
              ),
              onChanged: (value) {
                setState(() {
                  checked = value ?? false;
                });
              },
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
              child: GFButton(
                onPressed: () {},
                shape: GFButtonShape.pills,
                fullWidthButton: true,
                textColor: Colors.white,
                size: GFSize.LARGE,
                color: GFColors.PRIMARY,
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                text: "S'inscrire",
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                padding: EdgeInsets.only(left: 40, right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildSocial(image: Image.asset("assets/images/apple.png")),
                    buildSocial(image: Image.asset("assets/images/google.png")),
                    buildSocial(
                        image: Image.asset("assets/images/facebook.png")),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous avez un compte ?"),
                  GestureDetector(
                    onTap: () {
                      Get.to(Login());
                    },
                    child: Text(
                      " Se connecter",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            )
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

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Choisissez la source de l\'image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Caméra'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Annuler'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('Aucune image sélectionnée.');
      }
    });
  }

 void _verifyDeviceCredentials() async {
  if (_deviceFormKey.currentState?.saveAndValidate() ?? false) {
    final id = _deviceFormKey.currentState?.fields['identifiant']?.value;
    final password = _deviceFormKey.currentState?.fields['motDePasseDispositif']?.value;

    try {
      // Référence à la collection "Dispositifs" dans Firestore
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Dispositifs')
          .where('id', isEqualTo: id)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Les identifiants du dispositif sont valides
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        Get.snackbar("Succès", "Dispositif vérifié avec succès");
      } else {
        // Les identifiants sont incorrects
        Get.snackbar("Erreur", "Identifiants incorrects");
      }
    } catch (e) {
      print('Erreur lors de la vérification des identifiants : $e');
      Get.snackbar("Erreur", "Une erreur est survenue lors de la vérification");
    }
  }
}

  Widget buildChamp(
      {required String name,
      required String labelText,
      required String hintText,
      bool obscureText = false,
      Widget? suffixIcon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: FormBuilderTextField(
        name: name,
        obscureText: obscureText,
        cursorColor: Colors.green,
        validator: FormBuilderValidators.required(
            errorText: "Veuillez remplir ce champ"),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}
