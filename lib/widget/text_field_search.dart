import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

class TextFielSearch extends StatelessWidget {
  const TextFielSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
              children: [
                Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Recherche...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0), // Bordure arrondie
                      borderSide:  BorderSide(
                        color: greenColor, // Couleur de la bordure
                        width: 1.0, // Épaisseur de la bordure
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0), // Bordure arrondie
                    borderSide:  BorderSide(
                      color: greenColor, // Couleur de la bordure quand le champ est focalisé
                      width: 2.0, // Épaisseur de la bordure
                    ),
                    ),
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0), // Bordure arrondie
                  borderSide: BorderSide(
                    color: greyColor, // Couleur de la bordure quand le champ est désactivé
                    width: 1.0, // Épaisseur de la bordure
                  ),
              ),
                    contentPadding:  const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
              ),
              const SizedBox(width: 16), // Espacement entre le champ de recherche et l'icône
              IconButton(
                icon: Icon(Icons.filter_list, color: greyColor,),
                onPressed: null,
              ),
              ],
            );
  }
}