import 'package:asd/providers/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/cardConfig.dart';
import '../../providers/userProvider.dart';
import '../../utils/assets.dart';
import '../home.dart';
import '../welcomeScreen.dart';

class Config extends StatelessWidget {
  const Config({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: -screenHeight * 0.4,
              left: screenWidth / 2 - 340,
              child: Container(
                width: 680,
                height: 680,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal,
                ),
              ),
            ),
            // Icono de retroceso
            Positioned(
              top: screenHeight * 0.07,
              left: screenWidth * 0.05,
              child: IconAppBar(
                icon: LineAwesomeIcons.angle_left_solid,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Texto de "Configuración"
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.34,
              child: const Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.07,
              right: screenWidth * 0.05,
              child: IconButton(
                onPressed: () {
                  themeProvider.toggleTheme(!isDark);
                },
                icon:
                    Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(0, 140),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(Assets.imagesSplash),
                        backgroundColor: Colors.white60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userProvider.usuario ?? 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(0, 300),
                  child: Column(
                    children: [
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.bell,
                        text1: 'Notificaciones',
                        text2: 'Personaliza tus anuncios',
                        onTap: () {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.id_card,
                        text1: 'Datos Personales',
                        text2: 'Edita tus datos personales',
                        onTap: () {},
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.user_shield_solid,
                        text1: 'Cambio de Contraseña',
                        text2: 'Elige una nueva contraseña',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.80),
                  GestureDetector(
                    onTap: () =>
                        cerrarSesion(context), // Llama al método cerrarSesion
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LineAwesomeIcons.sign_out_alt_solid),
                        SizedBox(width: 8),
                        Text(
                          'Cerrar Sesion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
