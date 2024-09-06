import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

// Widget Cellule
class CelluleProduitsWidget extends StatelessWidget {
  final String imagePath;
  final String description;
  final int index; // Ajout d'un index pour afficher le numéro

  const CelluleProduitsWidget(
      {super.key,
      required this.imagePath,
      required this.description,
      required this.index});

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
                    width: 60,
                    height: 60,
                    child: imagePath.isNotEmpty
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Afficher l'image par défaut en cas d'erreur de chargement
                              return Image.asset(
                                'assets/images/pomme_noir.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/pomme_noir.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Text(
                      '$description',
                      style: TextStyle(
                          color: blackColor,
                          fontSize: 15,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top:
                -15, // Ajuste cette valeur pour que le cercle soit complètement visible
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                      3, 75, 5, 1), // Couleur verte à l'intérieur du cercle
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: Colors
                          .white, // Numéro en blanc pour contraster avec le vert
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
