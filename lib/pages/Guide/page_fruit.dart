import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/models/produit_model.dart';

class FruitsPage extends StatefulWidget {
  const FruitsPage({super.key});

  @override
  State<FruitsPage> createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage> {
  bool isFraisMode = true; // Mode de conservation par défaut

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Frais",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      color: const Color.fromARGB(255, 218, 234, 248),
                      borderRadius: BorderRadius.circular(15)),
                ),
                Icon(Icons.restart_alt),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Produit orange = new Produit(
                  categorieProduit: "1",
                  description:
                      "L'orange est un agrume originaire d'Asie, riche en vitamine C, fibres et antioxydants, qui renforce le système immunitaire, améliore la digestion, et favorise la santé de la peau et du cœur. En plus d'être consommée fraîche ou en jus, elle est utilisée en cuisine et en cosmétique pour ses multiples bienfaits.",
                  id: "1",
                  image: "assets/images/orange.png",
                  modeConservation: "frais",
                  nom: "Orange",
                  tempMax: "10",
                  tempMin: "7");

              showDetailProduit(produit: orange);
            },
            subtitle: Text(
              "L'orange est un agrume originaire d'Asie, riche en vitamine C, fibres et antioxydants, qui renforce le système immunitaire, améliore la digestion, et favorise la santé de la peau et du cœur. En plus d'être consommée fraîche ou en jus, elle est utilisée en cuisine et en cosmétique pour ses multiples bienfaits.",
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            title: Text("Orange"),
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/images/orange.png"),
            ),
          ),
          ListTile(
            subtitle: Text(
              "L'orange est un agrume originaire d'Asie, riche en vitamine C, fibres et antioxydants, qui renforce le système immunitaire, améliore la digestion, et favorise la santé de la peau et du cœur. En plus d'être consommée fraîche ou en jus, elle est utilisée en cuisine et en cosmétique pour ses multiples bienfaits.",
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            title: Text("Pomme"),
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/images/ananas.png"),
            ),
          )
        ],
      ),
    ));
  }

  void showDetailProduit({required Produit produit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet de contrôler la hauteur
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false, // Permet de ne pas s'étendre immédiatement
          initialChildSize: 0.3, // Hauteur initiale (30% de la page)
          minChildSize: 0.1, // Hauteur minimale (10% de la page)
          maxChildSize: 0.9, // Hauteur maximale (100% de la page)
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 16, right: 16, bottom: 8),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage(produit.image) as ImageProvider,
                    ),
                    Text(produit.nom),
                    Divider(),
                    Text(produit.description),
                    Divider(),
                    Text("Plage de conservation au frais"),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: greenColorTransparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '℃',
                        style: TextStyle(
                          fontSize: 20,
                          color: greenColor,
                          fontWeight: FontWeight.bold,
                        ),
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
}
