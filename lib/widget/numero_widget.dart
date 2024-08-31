import 'package:flutter/material.dart';

class NumeroWidget extends StatelessWidget {
  final int numero;

  const NumeroWidget({super.key, required this.numero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: Text(
            "$numero",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
