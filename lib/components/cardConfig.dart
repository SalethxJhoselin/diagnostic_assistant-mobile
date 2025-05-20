import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/themeProvider.dart';
import '../screens/home.dart';

class CardConfig extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon1;
  final String text1;
  final String text2;
  final VoidCallback onTap;

  const CardConfig(
      {super.key,
      required this.width,
      required this.height,
      required this.icon1,
      required this.text1,
      required this.text2,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.grey[850] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1), // Sombra suave
                blurRadius: 10,
                offset: const Offset(0, 4), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconHome(icon: icon1),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Alineación a la izquierda
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        text2,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                LineAwesomeIcons.angle_right_solid,
                size: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
        ));
  }
}
