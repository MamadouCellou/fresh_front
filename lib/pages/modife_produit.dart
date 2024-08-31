import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';

class ModifProduit extends StatefulWidget {
  const ModifProduit({super.key});

  @override
  State<ModifProduit> createState() => _ModifProduitState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _ModifProduitState extends State<ModifProduit> {
  // List of items for the dropdown
  List<String> aliments = ['Orange', 'Pomme', 'Banane', 'Mangue'];
  String selectedAliment = 'Orange';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Modifier produit frais",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Espace entre les widgets
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image:
                                    AssetImage("assets/images/orange.png"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: GestureDetector(
                              onTap: () {
                                // Logique pour modifier l'image
                              },
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(3, 75, 5, 1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
                      // Dropdown for selecting aliment
                      FormBuilderDropdown<String>(
                        name: 'aliment',
                        initialValue: selectedAliment,
                        decoration: InputDecoration(
                          labelText: 'Aliment',
                          border: OutlineInputBorder(),
                        ),
                        items: aliments.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAliment = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Editable fields
                      buildEditableField(
                          'Prix du produit', 'prix', TextInputType.number),
                      SizedBox(height: 10),
                      buildEditableField(
                          'Description', 'description', TextInputType.text),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Espace entre le contenu et les boutons
            // Row containing buttons 'Modifier' and 'Annuler'
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      final values = _formKey.currentState!.value;
                      print("Modifications sauvegardées avec valeurs: $values");

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Produit modifié')));
                    }
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.greenAccent, width: 2),
                      ),
                    ),
                    shadowColor: WidgetStateProperty.all<Color>(
                        Colors.greenAccent.withOpacity(0.5)),
                    elevation: WidgetStateProperty.all<double>(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Modifier",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Modification annulée')),
                    );

                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    shadowColor: WidgetStateProperty.all<Color>(
                        Colors.redAccent.withOpacity(0.5)),
                    elevation: WidgetStateProperty.all<double>(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Annuler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espace en bas de l'écran
          ],
        ),
      ),
    );
  }

  // Function to build an editable field using FormBuilder
  Widget buildEditableField(
      String label, String name, TextInputType inputType) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      validator: FormBuilderValidators.required(),
    );
  }
}
