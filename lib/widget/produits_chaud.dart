import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

// Widget Cellule
class CelluleProduitsChaudWidget extends StatelessWidget {
  final String imagePath;
  final String name;

  const CelluleProduitsChaudWidget({
    super.key,
    required this.imagePath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 6),
      child: Stack(
        clipBehavior: Clip.none, // Permet au cercle de sortir de la limite
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: greenColor, // Couleur de la bordure
                width: 1.0, // Épaisseur de la bordure
              ),
              borderRadius:
                  BorderRadius.circular(10.0), // Rayons des coins de la bordure
            ),
            child: SizedBox(
              width: 110,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(imagePath),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Text(
                      '$name',
                      style: TextStyle(
                          color: blackColor,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
