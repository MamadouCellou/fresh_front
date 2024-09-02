import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:fresh_front/widget/numero_produit.dart';

class PageFroidProduct extends StatefulWidget {
  @override
  _PageFroidProductState createState() => _PageFroidProductState();
}

class _PageFroidProductState extends State<PageFroidProduct> {
  bool _isExpandedFroidProduits = true;

  final List<Map<String, String>> produits = List.generate(
    12,
    (index) => {
      'imagePath': 'assets/images/ananas.png',
      'name': 
     'Produit $index'
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:null,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Compartiment Froid",
                   style: TextStyle(
                    fontSize: 20,
                    color: greenColor,
                    fontWeight: FontWeight.bold
                   ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const CardWidget(
              height: 100,
              width: 200,
              temperature: "30",
              title: "Temperature actuelle",
            ),
             const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Text(
                  "La liste des produits",
                   style: TextStyle(
                    fontSize: 15,
                    color: blackColor,
                    fontWeight: FontWeight.bold
                   ),
                ),
              ],
            ),
             const SizedBox(
              height: 15,
            ),
            _buildAnimatedContainer(
              _isExpandedFroidProduits,
              _buildProduitGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureRow(String label, String temperature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Icon(Icons.thermostat),
            Text(
              temperature,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  
  Widget _buildAnimatedContainer(bool isExpanded, Widget content) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? null : 0,
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }

  Widget _buildProduitGrid() {
    return GridView.builder(
      itemCount: produits.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final produit = produits[index];
        return GestureDetector(
          onTap: () {
            // Gérer l'affichage du produit
          },
          onLongPress: () {
            // Gérer la modification ou suppression du produit
          },
          child: CelluleProduitsWidget(
            index: index + 1,
            imagePath: produit['imagePath']!,
            name: produit['name']!,
          ),
        );
      },
    );
  }
}
