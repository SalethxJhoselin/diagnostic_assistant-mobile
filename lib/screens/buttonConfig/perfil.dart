import 'package:asd/components/BottonChange.dart';
import 'package:asd/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/themeProvider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  PerfilPageState createState() => PerfilPageState();
}

class PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    //final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    var isDark = themeProvider.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.toggleTheme(!isDark);
            },
            icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/usuarioLogo.png'),
              ),
              const SizedBox(height: 10),
              const Text(
                /*userProvider.nombre ??*/ 'Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                /*userProvider.email ?? */ 'Correo',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              BottonChange(
                  colorBack: Colors.teal,
                  colorFont: Colors.white,
                  textTile: 'Informacion Personal',
                  onPressed: () {},
                  width: 200),
              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.white30 : Colors.black38),
              const _ListTile(
                  "Configuración", LineAwesomeIcons.cog_solid, true),
              const _ListTile("Historial", Icons.history_outlined, true),
              Divider(color: isDark ? Colors.white30 : Colors.black38),
              const _ListTile("Información", Icons.info_outline, true),
              ListTile(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const WelcomeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color.fromARGB(255, 196, 205, 209)),
                  child: const Icon(
                    Icons.logout_outlined,
                    color: Colors.black45,
                  ),
                ),
                title: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile(this.title, this.icon, this.isIcon);
  final String title;
  final IconData icon;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color.fromARGB(255, 196, 205, 209)),
        child: Icon(
          icon,
          color: Colors.black45,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: isIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color.fromARGB(255, 233, 238, 241)),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
              ),
            )
          : null,
    );
  }
}
