import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:medical_record_movil/screens/RecetasMedicas.dart';
import 'package:medical_record_movil/screens/consultas.dart';
import 'package:medical_record_movil/screens/historial.dart';
import 'package:medical_record_movil/screens/reservaCitas.dart';
import 'package:medical_record_movil/screens/tratamientos.dart';
import 'package:provider/provider.dart';

import '../components/cardConfig.dart';
import '../components/cardHome.dart';
import '../components/fadeThroughPageRoute.dart';
import '../providers/themeProvider.dart';
import '../providers/userProvider.dart';
import 'buttonConfig/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return '¡Buenos días, ';
    } else if (hour < 18) {
      return '¡Buenas tardes, ';
    } else {
      return '¡Buenas noches, ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final userProvider = Provider.of<UserProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bienvenidaText = getGreeting() + (userProvider.usuario ?? 'Usuario');

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: -screenHeight * 0.4,
              left: screenWidth / 2 - 290,
              child: Container(
                width: 580,
                height: 580,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.05,
              child: Text(
                bienvenidaText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.07,
              right: screenWidth * 0.2,
              child: const IconAppBar(
                icon: LineAwesomeIcons.bell,
                onPressed: null,
              ),
            ),
            Positioned(
              top: screenHeight * 0.07,
              right: screenWidth * 0.05,
              child: IconAppBar(
                icon: LineAwesomeIcons.cog_solid,
                onPressed: () {
                  Navigator.of(context).push(
                    FadeThroughPageRoute(
                      page: const Config(),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: screenHeight * 0.15,
              left: (screenWidth - 300) / 2,
              child: Container(
                width: 300,
                height: 180,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del usuario
                    Text(
                      userProvider.nombre ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Título de las citas
                    const Text(
                      'Tus Próximas Citas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.4,
                  ),
                  Container(
                    width: double.infinity, // Hace que el Row ocupe todo el ancho disponible
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centrar contenido horizontalmente
                      children: [
                        Expanded(  // Hace que el primer cardHome ocupe proporcionalmente el espacio
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CardHome(
                              text: 'Reservar Cita',
                              icon: LineAwesomeIcons.notes_medical_solid,
                              onTap: () {
                                Navigator.of(context).push(
                                  FadeThroughPageRoute(
                                    page: const ReservarCitasPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(  // Hace que el segundo cardHome ocupe proporcionalmente el espacio
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CardHome(
                              text: 'Historial Clinico',
                              icon: LineAwesomeIcons.file_medical_solid,
                              onTap: () {
                                Navigator.of(context).push(
                                  FadeThroughPageRoute(
                                    page: const HistorialClinicoPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Descubre todos ',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Nuestros Servicios',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    children: [
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.user_md_solid,
                        text1: 'Consulta Médica',
                        text2: 'Encuentre sus consultas',
                        onTap: () {
                          Navigator.of(context).push(
                            FadeThroughPageRoute(
                              page: const ConsultasPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.capsules_solid,
                        text1: 'Diagnosticos',
                        text2: 'Encuentre sus diagnosticos',
                        onTap: () {
                          Navigator.of(context).push(
                            FadeThroughPageRoute(
                              page: const RecetasMedicasPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      CardConfig(
                        width: 320,
                        height: 90,
                        icon1: LineAwesomeIcons.brain_solid,
                        text1: 'Tratamientos',
                        text2: 'Servicios de psicología',
                        onTap: () {
                          Navigator.of(context).push(
                            FadeThroughPageRoute(
                              page: const TratamientosPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconHome extends StatelessWidget {
  const IconHome({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.teal,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

class IconAppBar extends StatelessWidget {
  final IconData icon;
  final dynamic onPressed;

  const IconAppBar({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.black,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
