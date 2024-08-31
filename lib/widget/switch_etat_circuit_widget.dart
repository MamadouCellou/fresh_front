import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

class SwitchEtatCircuitWidget extends StatelessWidget {
  
  final void Function(bool)? onChange;
  final bool isSlider;
  final String title;
  
  const SwitchEtatCircuitWidget({
    super.key, 
    required this.onChange,
    required this.isSlider,
    required this.title
  });
  
  @override
  Widget build(BuildContext context) {
    return  SwitchListTile(
       value: isSlider,
       onChanged: onChange,
       activeColor: greenColor,
       title: Container(
      padding: const  EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isSlider ? greenColorTransparent : redColorTransparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child:   Center(
        child: Text(isSlider ? "Allumé" : "Eteint",
         style: TextStyle(
          fontSize: 20,
          color: isSlider ? greenColor : redColor,
          fontWeight: FontWeight.bold
        )
        ),
      ),
    ),
   );
  }
}