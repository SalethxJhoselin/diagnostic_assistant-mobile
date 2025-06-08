import 'package:animations/animations.dart';
import 'package:asd/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/themeProvider.dart';
import 'reservaCitas.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  NavigationState createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  int selectedIndex = 0;

  final List<Widget> screens = [const HomePage(), const ReservarCitasPage()];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: IndexedStack(index: selectedIndex, children: screens),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff0e1415) : const Color(0xfff9f9ff),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: isDark
                ? const Color.fromARGB(255, 11, 200, 181)
                : Colors.teal,
            unselectedItemColor: isDark ? Colors.grey : Colors.black54,
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: LineAwesomeIcons.home_solid,
                  isSelected: selectedIndex == 0,
                  isDark: isDark,
                ),
                label: "Home",
                tooltip: "Página Principal",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: LineAwesomeIcons.calendar_check,
                  isSelected: selectedIndex == 1,
                  isDark: isDark,
                ),
                label: "Citas",
                tooltip: "Página de Reserva de Citas",
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(
                  icon: LineAwesomeIcons.user,
                  isSelected: selectedIndex == 2,
                  isDark: isDark,
                ),
                label: "Perfil",
                tooltip: "Tu Perfil",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon({
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark
                  ? Colors.teal.withOpacity(0.3)
                  : Colors.teal.withOpacity(0.15))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }
}
