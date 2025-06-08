import 'package:asd/components/wabeClipper.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title1;
  const CustomAppBar({super.key, required this.title1});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Colores adaptativos
    final gradientStart = colorScheme.primaryContainer;
    final gradientEnd = isDarkMode ? Colors.teal.shade700 : Colors.teal;
    final iconBackgroundColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.1);
    final iconColor = isDarkMode ? Colors.white : Colors.black87;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return AppBar(
      flexibleSpace: ClipPath(
        clipper: DoubleWaveClipper(),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, color: iconColor),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            title1,
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}
