import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

class SubTitleCompartimentWidget extends StatelessWidget {
  final bool isExpanded;
  final String title;
  final VoidCallback  onPressed;
  final double numberPadding;
  
  const SubTitleCompartimentWidget({
    super.key,
    required this.isExpanded,
    required this.title,
    required this.onPressed, 
    this.numberPadding = 0
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(numberPadding),
      child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Text(
           title,
           style: TextStyle(
             fontSize: 18,
              color: blackColor,
             fontWeight: FontWeight.bold
           ),
         ),
         IconButton(
           icon: Icon( isExpanded
               ? Icons.arrow_drop_up
               : Icons.arrow_drop_down,
           color: greyColor,
           ),
           onPressed: onPressed
         ),
       ],
         ),
    );
  }
}