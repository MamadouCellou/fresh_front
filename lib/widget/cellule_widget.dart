import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';


class CelluleWidget extends StatelessWidget {
  final  String imagePath;
  final String name;
  const CelluleWidget({super.key, required this.imagePath, required this.name});

 
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
              height: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(imagePath),
                  ),

                 Text(name + " ...", style: TextStyle(
                    color: blackColor,
                    fontSize: 10,
                    ),),
                ],
              ),
          )
    );
  }
}
