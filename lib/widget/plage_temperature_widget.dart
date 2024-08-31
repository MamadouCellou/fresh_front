import 'package:fresh_front/constant/colors.dart';
import 'package:flutter/material.dart';

class PlageTemperatureWidget extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool isEnabled;

  const PlageTemperatureWidget({
    super.key,
    required this.minController,
    required this.maxController,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                  controller: minController,
                  enabled: isEnabled,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const  EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: greenColorTransparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child:   Text('℃',
                 style: TextStyle(
                  fontSize: 20,
                  color: greenColor,
                  fontWeight: FontWeight.bold
                )
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: TextField(
                  controller: maxController,
                  enabled: isEnabled,
                  cursorColor: blackColor,
                  keyboardType: TextInputType.number,
                  decoration: const  InputDecoration(
                    labelText: 'Max',
                    border: InputBorder.none, 
                ),
              ),
              ),
              
            ],
          ),
          const Divider()
        ],
      ),
    );
  }
}
