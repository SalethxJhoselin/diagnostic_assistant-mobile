import 'package:asd/components/Card.dart';
import 'package:asd/components/CustomAppBar.dart';
import 'package:asd/components/ProfileAvatar.dart';
import 'package:asd/components/actionButton.dart';
import 'package:asd/components/infoItem.dart';
import 'package:asd/providers/themeProvider.dart';
import 'package:asd/screens/editProfile.dart';
import 'package:asd/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../utils/assets.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _editarDatos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: CustomAppBar(title1: 'Perfil de Usuario'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            // Sección de perfil
            ProfileCard(
              child: Column(
                children: [
                  const ProfileAvatar(imagePath: Assets.imagesLogoUsuario),
                  const SizedBox(height: 16),
                  Text(
                    '${userProvider.name ?? 'Usuario'} '
                    '${userProvider.aPaternal ?? ''} '
                    '${userProvider.aMaternal ?? ''}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProvider.email ?? 'Correo no disponible',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón para cambiar tema
                  ActionButton(
                    icon: isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon,
                    title: isDark ? 'Modo Claro' : 'Modo Oscuro',
                    color: Colors.teal,
                    isDark: isDark,
                    showChevron: true,
                    onPressed: () => themeProvider.toggleTheme(!isDark),
                  ),
                ],
              ),
            ),
            // Sección de información personal
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Información Personal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          LineAwesomeIcons.edit,
                          size: 20,
                          color: Colors.teal,
                        ),
                        onPressed: () => _editarDatos(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (userProvider.ci != null)
                    InfoItem(
                      icon: LineAwesomeIcons.id_card,
                      label: 'CI',
                      value: userProvider.ci?.toString() ?? 'No disponible',
                    ),
                  if (userProvider.phone != null)
                    InfoItem(
                      icon: LineAwesomeIcons.phone_alt_solid,
                      label: 'Teléfono',
                      value: userProvider.phone?.toString() ?? 'No disponible',
                    ),
                  if (userProvider.birthDate != null)
                    InfoItem(
                      icon: LineAwesomeIcons.calendar,
                      label: 'Fecha de Nacimiento',
                      value: DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(userProvider.birthDate!)),
                    ),
                ],
              ),
            ),
            // Botones de acciones
            Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ActionButton(
                    icon: LineAwesomeIcons.sign_out_alt_solid,
                    title: 'Cerrar Sesión',
                    color: Colors.red,
                    isDark: isDark,
                    showChevron: false,
                    onPressed: () => _cerrarSesion(context),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
