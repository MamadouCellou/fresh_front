import 'dart:convert';
import 'dart:io';

import 'package:fresh_front/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../constant/colors.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

Color couleurApp = Color.fromRGBO(17, 186, 24, 1);

String _selectedGenre = "";

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _passwordVisible = false;
  bool _mandaPasswordVisible = false;

  bool? checked = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String uploadUrlUser =
      'http://$ip:8000/api/utilisateurs/'; // Remplacez par l'URL de votre API
  final String uploadUrlDis = 'http://$ip:8000/api/dispositifs/';
  final String uploadUrlUserDis =
      'http://$ip:8000/api/utilisateurs-dispositifs/'; // Remplacez par l'URL de votre API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        textAlign: TextAlign.left,
                        "Vos informations personnelles",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Renseignez vos informations en dessous ou inscrivez-vous avec votre compte social",
                      ),
                    ),
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: FormBuilderTextField(
                              name: "nom",
                              cursorColor: couleurApp,
                              validator: FormBuilderValidators.required(
                                  errorText: "Veillez remplir ce champ"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                labelText: "Nom",
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: "Entrez votre nom",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                              name: "prenom",
                              cursorColor: couleurApp,
                              validator: FormBuilderValidators.required(
                                  errorText: "Veillez remplir ce champ"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                labelText: "Prénom",
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: "Entrez votre prénom",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: couleurApp),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
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
                                hintText:
                                    "Sélectionnez votre date de naissance",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                              name: "profession",
                              cursorColor: couleurApp,
                              validator: FormBuilderValidators.required(
                                  errorText: "Veillez remplir ce champ"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                labelText: "Profession",
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: "Entrez votre profession",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: couleurApp),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
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
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                                  height: 200,
                                )
                              : SizedBox(),
                          Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 30),
                              child: Text(
                                "Informations de votre MandaFresh",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: FormBuilderTextField(
                              name: "identifiant",
                              cursorColor: couleurApp,
                              validator: FormBuilderValidators.required(
                                  errorText: "Veillez remplir ce champ"),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                labelText: "Identifiant",
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: "Identifiant du MandaFresh",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
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
                              name: "motDePasseDispositif",
                              cursorColor: couleurApp,
                              validator: FormBuilderValidators.required(
                                  errorText: "Veillez remplir ce champ"),
                              obscureText: !_mandaPasswordVisible,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.1),
                                labelText: "Mot de passe du MandaFresh",
                                labelStyle: TextStyle(fontSize: 20),
                                hintText: "Entrez le mot de passe",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _mandaPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _mandaPasswordVisible =
                                          !_mandaPasswordVisible;
                                    });
                                  },
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: couleurApp),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
                            padding: EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 20),
                            child: GFButton(
                              onPressed: _submitForm,
                              shape: GFButtonShape.pills,
                              fullWidthButton: true,
                              textColor: Colors.white,
                              size: GFSize.LARGE,
                              color: GFColors.PRIMARY,
                              textStyle: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                                          "assets/images/facebook.png")),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  Future<void> _submitForm() async {
    try {
      if (_formKey.currentState?.saveAndValidate() ?? false) {
        final formData = _formKey.currentState?.value;
        final identifiant = formData?['identifiant'];
        final motDePasseDispositif = formData?['motDePasseDispositif'];

        // Étape 1: Vérifier les informations du dispositif
        bool dispositifValide =
            await _verifierDispositif(identifiant, motDePasseDispositif);

        if (dispositifValide) {
          // Étape 2: Inscrire l'utilisateur et le lier au dispositif
          await _inscrireEtLierUtilisateur(formData, identifiant);
        }
      } else {
        print('Formulaire invalide');
      }
    } catch (e) {
      print('Exception : $e');
    }
  }

  Future<bool> _verifierDispositif(
      String identifiant, String motDePasseDispositif) async {
    try {
      final dispositifsResponse = await http.get(
        Uri.parse(uploadUrlDis),
      );

      if (dispositifsResponse.statusCode == 200) {
        // Décodez la réponse JSON
        final Map<String, dynamic> responseJson =
            jsonDecode(dispositifsResponse.body);

        // Accédez à la liste des dispositifs
        final List dispositifs = responseJson['results'];

        // Cherchez le dispositif correspondant
        final dispositifTrouve = dispositifs.firstWhere(
          (dispositif) =>
              dispositif['id'] == identifiant &&
              dispositif['mot_de_passe_dispositif'] == motDePasseDispositif,
          orElse: () => null,
        );

        if (dispositifTrouve != null) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Identifiant ou mot de passe du dispositif incorrect')),
          );
          return false;
        }
      } else {
        print(
            'Erreur lors de la récupération des dispositifs : ${dispositifsResponse.statusCode}');
        print('Réponse : ${dispositifsResponse.body}');
        return false;
      }
    } catch (e) {
      print('Exception lors de la vérification du dispositif : $e');
      return false;
    }
  }

  Future<void> _inscrireEtLierUtilisateur(
      Map<String, dynamic>? formData, String identifiant) async {
    try {
      final dateNaissance = formData?['dateNaissance'];
      final formattedDateNaissance = dateNaissance != null
          ? '${dateNaissance.year.toString().padLeft(4, '0')}-${dateNaissance.month.toString().padLeft(2, '0')}-${dateNaissance.day.toString().padLeft(2, '0')}'
          : null;

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrlUser));

      // Utiliser les données du formulaire
      request.fields['nom'] = formData?['nom'] ?? '';
      request.fields['prenom'] = formData?['prenom'] ?? '';
      request.fields['profession'] = formData?['profession'] ?? '';
      request.fields['genre'] = _selectedGenre;
      request.fields['email'] = formData?['email'] ?? '';
      request.fields['mot_de_passe'] = formData?['password'] ?? '';
      request.fields['date_de_naissance'] = formattedDateNaissance ?? '';
      request.fields['cree_a'] = DateTime.now().toIso8601String();
      request.fields['modifie_a'] = DateTime.now().toIso8601String();

      // Ajouter l'image au formulaire si elle existe
      if (_imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        );
        request.files.add(multipartFile);
      }

      // Envoyer la requête
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final utilisateurData =
            jsonDecode(await response.stream.bytesToString());

        if (utilisateurData.containsKey('id')) {
          final utilisateurId = utilisateurData['id'];

          // Étape 3: Lier l'utilisateur au dispositif
          final utilisateurDispositifResponse = await http.post(
            Uri.parse(uploadUrlUserDis),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'cree_a': DateTime.now().toIso8601String(),
              'modifie_a': DateTime.now().toIso8601String(),
              'utilisateur': utilisateurId,
              'dispositif': identifiant,
            }),
          );

          if (utilisateurDispositifResponse.statusCode == 200 ||
              utilisateurDispositifResponse.statusCode == 201) {
            showTopSnackBar(
              Overlay.of(context),
              CustomSnackBar.success(
                message: "Inscription réussie. Veillez vous connecter !",
              ),
            );
            Get.to(Login()); // Rediriger vers le Dashboard
          } else {
            print(
                'Erreur lors de la liaison avec le dispositif : ${utilisateurDispositifResponse.statusCode}');
            print('Réponse : ${utilisateurDispositifResponse.body}');
          }
        } else {
          print('Erreur lors de l\'inscription utilisateur : Pas d\'ID trouvé');
        }
      } else {
        print(
            'Erreur lors de l\'inscription utilisateur : ${response.statusCode}');
        print('Réponse : ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print(
          'Exception lors de l\'inscription et de la liaison du dispositif : $e');

      // Affiche l'erreur dans un Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'), // Affiche le message d'erreur
          backgroundColor: Colors
              .red, // Vous pouvez changer la couleur de fond pour indiquer une erreur
          duration: Duration(
              seconds: 3), // Durée pendant laquelle le snackbar reste visible
        ),
      );
    }
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
