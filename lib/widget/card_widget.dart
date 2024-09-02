import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';


class CardWidget extends StatelessWidget {
  final String title;
  final String temperature;
  final double width;
  final double height;
  const CardWidget({super.key, required this.title, required this.temperature,  this.width = 160,  this.height = 160});

  

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
              width: width,
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(title,  style: TextStyle(
                    color: blackColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                      
                      Text(temperature.toString() + " °C", style: TextStyle(
                    color: blackColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                    ),),
                    Icon(Icons.thermostat, size: 30, color: greenColor,),
                    ],
                  )
      
                ],
              ),
          )
    );
  }
}
