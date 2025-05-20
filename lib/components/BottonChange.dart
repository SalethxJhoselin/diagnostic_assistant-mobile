import 'package:flutter/material.dart';

class BottonChange extends StatelessWidget {
  final Color colorBack;
  final Color colorFont;
  final String textTile;
  final VoidCallback onPressed;
  final double width;

  const BottonChange(
      {super.key,
      required this.colorBack,
      required this.colorFont,
      required this.textTile,
      required this.onPressed,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: colorBack,
            side: BorderSide.none,
            shape: const StadiumBorder()),
        child: Text(
          textTile,
          style: TextStyle(
              fontSize: 14, color: colorFont, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
