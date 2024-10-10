import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/models/produit_model.dart';

class AlimentPage extends StatefulWidget {
  final type;
  const AlimentPage({Key? key, required this.type}) : super(key: key,);


  @override
  _AlimentPageState createState() => _AlimentPageState();
}

class _AlimentPageState extends State<AlimentPage> {
  // L'état de sélection pour "Frais" et "Chaud"
  List<bool> isSelected = [true, false]; // Par défaut, frais est sélectionné
  String collectionName =
      'SpecifiqueProduitFroid'; // Collection Firestore pour les fruits frais

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(15),
                isSelected: isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }

                    // Mise à jour de la collection en fonction du choix
                    collectionName = isSelected[0]
                        ? 'SpecifiqueProduitFroid' // Pour les fruits frais
                        : 'SpecifiqueProduitChaud'; // Pour les fruits chauds
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Frais', style: TextStyle(fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Chaud', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(collectionName)
                  .where('categorie_produit',
                      isEqualTo: widget.type) // Filtrer les fruits
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final produits = snapshot.data!.docs;

                if (produits.isEmpty) {
                  return Center(child: Text("Aucun fruit trouvé"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: produits.length,
                  itemBuilder: (context, index) {
                    final produit = produits[index];
                    return ListTile(
                      onTap: () {
                        // Affichage des détails du produit
                        if (collectionName == "SpecifiqueProduitFroid") {
                          showDetailProduit(
                            produit: Produit(
                              categorieProduit: produit['categorie_produit'],
                              description: produit['description'],
                              id: produit['id'],
                              image: produit['image'],
                              nom: produit['nom'],
                              tempMin: produit['temp_min'],
                              tempMax: produit['temp_max'],
                            ),
                          );
                        } else {
                          showDetailChaud(
                              produit: ProduitChaud(
                                  categorieProduit:
                                      produit['categorie_produit'],
                                  description: produit['description'],
                                  id: produit['id'],
                                  image: produit['image'],
                                  nom: produit['nom'],
                                  dure: produit['dure'],
                                  dure_soleil_min: produit['dure_soleil_min'],
                                  dure_soleil_max: produit['dure_soleil_max'],
                                  temp_soleil_min: produit['temp_soleil_min'],
                                  temp_soleil_max: produit['temp_soleil_max']));
                        }
                      },
                      subtitle: Text(
                        produit['description'],
                        style: TextStyle(overflow: TextOverflow.ellipsis),
                      ),
                      title: Text(produit['nom']),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(produit['image']),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour afficher les détails du produit (comme avant)
  void showDetailProduit({required Produit produit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image et nom du produit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(produit.image),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        produit.nom,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    Text(
                      produit.description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "Plage de conservation au frais",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.thermostat_outlined,
                                color: Colors.blueAccent, size: 30),
                            Text('${produit.tempMin}℃',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Min'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('~',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.thermostat_outlined,
                                color: Colors.redAccent, size: 30),
                            Text('${produit.tempMax}℃',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Max'),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Text(
                    "Aliments associés",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAssociatedFood(
                          'Banane',
                          'assets/images/banane.png',
                        ),
                        _buildAssociatedFood(
                          'Pomme',
                          'assets/images/pomme.png',
                        ),
                        _buildAssociatedFood(
                          'Fraise',
                          'assets/images/fraise.png',
                        ),
                        _buildAssociatedFood(
                          'Mangue',
                          'assets/images/banane.png',
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDetailChaud({required ProduitChaud produit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.1,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image et nom du produit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(produit.image),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        produit.nom,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    Text(
                      produit.description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(),
                    Text(
                      "Durée de sechage dans MandaSmart",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: Text("${produit.dure} Jour(s)",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.green)),
                      decoration: BoxDecoration(
                          color: Colors.green[100],
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.all(5),
                    ),
                    Divider(),
                    Text(
                      "Durée de sechage au soleil",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.timer,
                                color: Colors.blueAccent, size: 30),
                            Text('${produit.dure_soleil_min} Jour(s)',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Min'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('~',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.timer,
                                color: Colors.redAccent, size: 30),
                            Text('${produit.dure_soleil_max} Jour(s)',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Max'),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Text(
                      "Temperature sechage au soleil",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.thermostat_outlined,
                                color: Colors.blueAccent, size: 30),
                            Text('${produit.temp_soleil_min}℃',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Min'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('~',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.thermostat_outlined,
                                color: Colors.redAccent, size: 30),
                            Text('${produit.temp_soleil_max}℃',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            Text('Max'),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
// Fonction pour construire un aliment associé
Widget _buildAssociatedFood(String name, String imagePath) {
  return Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}


// Modèle Produit
