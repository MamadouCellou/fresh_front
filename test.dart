/* import 'dart:convert';
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
String errorText = "Veillez remplir ce champ";

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _passwordVisible = false;
  bool _mandaPasswordVisible = false;

  bool? checked = false;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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
                          buildChamp(
                              name: "identifiant",
                              hintText: "Entrer l'identifiant du dispositif",
                              labelText: "Identifiant"),
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
                              onPressed: () {},
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

  Widget buildChamp(
      {required String name,
      required String labelText,
      required String hintText,
      double paddingBottom = 20}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: FormBuilderTextField(
        name: name,
        cursorColor: couleurApp,
        validator: FormBuilderValidators.required(errorText: errorText),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 20),
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: couleurApp),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
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
 */