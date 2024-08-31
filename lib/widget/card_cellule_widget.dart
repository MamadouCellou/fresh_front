import 'package:fresh_front/widget/cellule_widget.dart';
import 'package:flutter/material.dart';

class SnapCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Container(
          
          height: 100.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const  <Widget>[
              CelluleWidget(
                imagePath: 'assets/images/mangue_1.png',
                 name: "Mangue : 5000 GNF"),
             SizedBox(width: 10,),
              CelluleWidget(
                imagePath: 'assets/images/orange.png',
                 name: "Orange : 5000 GNF"),
              SizedBox(width: 10,),
             CelluleWidget(
                imagePath: 'assets/images/ananas.png',
                 name: "Ananas : 6000 GNF"),
                 SizedBox(width: 10,),
             CelluleWidget(
                imagePath: 'assets/images/mangue_1.png',
                 name: "Orange : 5000 GNF"),
                 SizedBox(width: 10,),
               CelluleWidget(
                imagePath: 'assets/images/orange.png',
                 name: "Orange : 5000 GNF"),
            ],
          ),
        );
  }
}