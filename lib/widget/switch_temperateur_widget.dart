import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

class SwitchTemperateurWidget extends StatelessWidget {
  
  final void Function(bool)? onChange;
  final bool isSlider;
  final String title;
  
  const SwitchTemperateurWidget({super.key, this.onChange, required this.isSlider, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return  SwitchListTile(
         value: isSlider,
         onChanged: onChange,
         activeColor: greenColor,
         title:Text(
         title,
          style: TextStyle(
           fontSize: 18,
           color: blackColor 
         ),
       ) ,
   );
  }
}