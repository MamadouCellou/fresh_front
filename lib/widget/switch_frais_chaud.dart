import 'package:flutter/material.dart';

class SwitchFraisChaud extends StatefulWidget {
  @override
  _SwitchFraisChaudState createState() => _SwitchFraisChaudState();
}

class _SwitchFraisChaudState extends State<SwitchFraisChaud> {
  List<bool> isSelected = [true, false]; // Par défaut, le mode "Frais" est sélectionné

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(15),
      isSelected: isSelected,
      onPressed: (int index) {
        setState(() {
          // Désactive l'autre bouton et active celui sélectionné
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == index;
          }
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Frais', style: TextStyle(fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Chaud', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
