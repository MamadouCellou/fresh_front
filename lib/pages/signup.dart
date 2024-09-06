import 'dart:convert';
import 'dart:io';
import 'package:fresh_front/pages/home.dart';
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

String copieIdDispo = "";

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
              padding: const EdgeInsets.only(top: 100, bottom: 50),
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

  void _registerUser() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState?.fields['email']?.value;
      final password = _formKey.currentState?.fields['password']?.value;
      final nom = _formKey.currentState?.fields['nom']?.value;
      final prenom = _formKey.currentState?.fields['prenom']?.value;
      final dateNaissance =
          _formKey.currentState?.fields['dateNaissance']?.value;
      final profession = _formKey.currentState?.fields['profession']?.value;

      // Affiche le loader
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        // 1. Création de l'utilisateur avec email et mot de passe
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // 2. Upload de l'image de profil de l'utilisateur sur Firebase Storage
        String imageUrl = '';
        if (_imageFile != null) {
          imageUrl =
              await _uploadImageToFirebaseStorage(_imageFile!, prenom, email);
        }

        // 3. Sauvegarde des informations utilisateur dans Firestore
        await FirebaseFirestore.instance
            .collection('Utilisateurs')
            .doc(userCredential.user?.uid)
            .set({
          'nom': nom,
          'prenom': prenom,
          'date_naissance': dateNaissance,
          'email': email,
          'genre': _selectedGenre,
          'profession': profession,
          'image': imageUrl,
        });

        // 4. Lier l'utilisateur au dispositif dans la collection Users_dispo
        await FirebaseFirestore.instance.collection('Users_dispo').add({
          'date': DateTime.now(),
          'email_user': email,
          'id_dispo': copieIdDispo,
        });

        Get.back();

        showCustomSnackbar(
          message: "Inscription réussie! Veillez vous connecter.",
          type: "success",
        );
        Get.to(Login());
      } catch (e) {
        showCustomSnackbar(
          message: "Erreur d'inscription: ${e.toString()}",
          type: "error",
          colorText: Colors.white,
        );
      }
    }
  }

  Future<String> _uploadImageToFirebaseStorage(
      File imageFile, String userName, String email) async {
    try {
      // Détermination de l'extension du fichier
      String extension = path.extension(imageFile.path);
      if (extension.isEmpty) {
        extension =
            '.png'; // Définir une extension par défaut si aucune extension n'est trouvée
      }

      // Renommage de l'image avec le nom de l'utilisateur, son email et l'extension du fichier
      String fileName = '${userName}_${email.split('@')[0]}$extension';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images/$fileName');

      // Upload de l'image
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Récupération de l'URL de l'image uploadée
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      showCustomSnackbar(
        message: "Erreur lors du téléchargement de l'image",
        type: "error",
      );
      return '';
    }
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
                        hintText: "Selectionner votre genre",
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
                onPressed: _registerUser,
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
      // Simuler la vérification des identifiants du dispositif
      String identifiant =
          _deviceFormKey.currentState?.fields['identifiant']?.value;
      String motDePasseDispositif =
          _deviceFormKey.currentState?.fields['motDePasseDispositif']?.value;

      // Affiche le loader
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Vérification dans Firestore (remplacez avec votre logique réelle)
      bool credentialsAreValid = await verifyCredentials(
          identifiant, motDePasseDispositif); // Remplacer par la logique réelle

      if (credentialsAreValid) {
        Get.back();
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        showCustomSnackbar(
          message: "Dispositif vérifié avec succès!",
          type: "success",
        );
      } else {
        // Afficher une erreur si les identifiants sont incorrects
        showCustomSnackbar(
          message: "Identifiants incorrects, veuillez réessayer.",
          type: "error",
        );
      }
    }
  }

  Future<bool> verifyCredentials(
      String identifiant, String motDePasseDispositif) async {
    try {
      // Accéder à la collection 'Dispositifs' dans Firestore
      final collection = FirebaseFirestore.instance.collection('Dispositifs');
      // Chercher le document avec l'identifiant donné
      final querySnapshot = await collection
          .where('id', isEqualTo: identifiant)
          .where('password', isEqualTo: motDePasseDispositif)
          .get();

      // Vérifier si un document correspondant a été trouvé
      if (querySnapshot.docs.isNotEmpty) {
        copieIdDispo = identifiant;
        return true; // Les identifiants sont valides
      } else {
        return false; // Les identifiants sont invalides
      }
    } catch (e) {
      // Afficher une erreur si quelque chose se passe mal
      showCustomSnackbar(
        message: "Erreur lors de la vérification des identifiants",
        type: "error",
      );
      return false;
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
