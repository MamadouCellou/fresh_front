import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';



// Widget Cellule
class CelluleWidget extends StatelessWidget {
  final String imagePath;
  final String name;
  final int index; // Ajout d'un index pour afficher le numéro
  const CelluleWidget({super.key, required this.imagePath, required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: greenColor, // Couleur de la bordure
          width: 1.0, // Épaisseur de la bordure
        ),
        borderRadius: BorderRadius.circular(10.0), // Rayons des coins de la bordure
      ),
      child: SizedBox(
        width: 110,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$index', // Afficher le numéro
              style: TextStyle(
                color: blackColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(imagePath),
            ),
            Text(
              name + " ...",
              style: TextStyle(
                color: blackColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PageProduits extends StatefulWidget {
  @override
  _PageProduitsState createState() => _PageProduitsState();
}

class _PageProduitsState extends State<PageProduits> {
  bool _isExpanded = false;

  // Exemple de liste de produits
  final List<Map<String, String>> produits = List.generate(
    12,
    (index) => {
      'imagePath': 'assets/images/product_$index.png',
      'name': 'Produit $index'
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Compartiment froid',
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
              icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ],
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: _isExpanded ? 400 : 0,
          child: GridView.builder(
            itemCount: produits.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Nombre de colonnes
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final produit = produits[index];
              return CelluleWidget(
                imagePath: produit['imagePath']!,
                name: produit['name']!,
                index: index + 1, // Passer l'index pour l'afficher
              );
            },
          ),
        ),
      ],
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Grille de Produits'),
        ),
        body: Center(
          child: PageProduits(),
        ),
      ),
    );
  }
}
