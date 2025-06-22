import 'package:asd/components/Card.dart';
import 'package:asd/components/actionButton.dart';
import 'package:asd/components/wabeClipper.dart';
import 'package:asd/providers/themeProvider.dart';
import 'package:asd/screens/consulations.dart';
import 'package:asd/screens/diagnoses.dart';
import 'package:asd/screens/enfermedades.dart';
import 'package:asd/screens/patientHistory.dart';
import 'package:asd/screens/reservaCitas.dart';
import 'package:asd/screens/treatment.dart';
import 'package:asd/screens/userProfile.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../services/appointment_service.dart';
import '../components/fadeThroughPageRoute.dart';
import '../providers/userProvider.dart';
import '../services/tramientoService.dart';

import 'package:asd/screens/horarios_atencion.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = Colors.teal;
    final primaryContainer = colorScheme.primaryContainer;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: DoubleWaveClipper(),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryContainer,
                      isDark ? Colors.teal.shade700 : Colors.teal.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(context, onSurfaceColor, primaryColor),
                  _buildAppointmentsCard(context, surfaceColor, onSurfaceColor),
                  _buildMainActionsSection(primaryColor, onSurfaceColor),
                  _buildServicesSection(primaryColor, onSurfaceColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color textColor, Color iconColor) {
    final userProvider = Provider.of<UserProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: textColor,
                  ),
                ),
                Text(
                  userProvider.name ?? 'Usuario',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
              ),
              child: Icon(LineAwesomeIcons.user, color: iconColor),
            ),
            onPressed: () => Navigator.push(
              context,
              FadeThroughPageRoute(page: const UserProfilePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
  ) {
    return ProfileCard(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus Próximas Citas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: TratamientoService.getRecordatoriosPorPaciente(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: textColor),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  icon: LineAwesomeIcons.calendar,
                  message: 'No tienes citas próximas',
                  textColor: textColor,
                );
              }

              return _buildTodayTreatments(snapshot.data!, textColor);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTreatments(Map<String, dynamic> data, Color textColor) {
    final hoy = DateTime.now();
    final tratamientosHoy = <String>[];

    data.forEach((_, value) {
      final description = value['description'];
      final fechas = (value['dates'] as List<dynamic>)
          .map((d) => DateTime.parse(d))
          .toList();

      final tieneHoy = fechas.any(
        (fecha) =>
            fecha.year == hoy.year &&
            fecha.month == hoy.month &&
            fecha.day == hoy.day,
      );

      if (tieneHoy) tratamientosHoy.add(description);
    });

    if (tratamientosHoy.isEmpty) {
      return _buildEmptyState(
        icon: LineAwesomeIcons.notes_medical_solid,
        message: 'Hoy no tienes tratamientos',
        textColor: textColor,
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tratamientos para Hoy',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        ...tratamientosHoy.map(
          (t) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  LineAwesomeIcons.check_circle,
                  size: 16,
                  color: Colors.teal,
                ),
                Expanded(
                  child: Text(
                    t,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionsSection(Color primaryColor, Color textColor) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Acciones Rápidas',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            ActionButton(
              icon: LineAwesomeIcons.notes_medical_solid,
              title: 'Reservar Cita',
              color: Colors.teal,
              textColor: textColor,
              isDark: isDark,
              vertical: true,
              roundedIcon: true,
              onPressed: () {
                Navigator.push(
                  context,
                  FadeThroughPageRoute(page: const HorariosAtencionPage()),
                );
              },
            ),
            ActionButton(
              icon: LineAwesomeIcons.file_medical_solid,
              title: 'Historial Clínico',
              color: Colors.teal,
              textColor: textColor,
              isDark: isDark,
              vertical: true,
              roundedIcon: true,
              onPressed: () {
                Navigator.push(
                  context,
                  FadeThroughPageRoute(page: const PatientHistoryPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesSection(Color primaryColor, Color textColor) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Nuestros Servicios',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        Column(
          children: [
            ActionButton(
              icon: LineAwesomeIcons.brain_solid,
              title: 'Tratamientos',
              subtitle: 'Servicios de psicología',
              color: primaryColor,
              isDark: themeProvider.isDarkMode,
              showChevron: true,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(FadeThroughPageRoute(page: const TratamientosPage()));
              },
            ),
            const SizedBox(height: 12),
            ActionButton(
              icon: LineAwesomeIcons.user_md_solid,
              title: 'Consulta Médica',
              subtitle: 'Encuentre sus consultas',
              color: primaryColor,
              isDark: themeProvider.isDarkMode,
              showChevron: true,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(FadeThroughPageRoute(page: const ConsultasPage()));
              },
            ),
            const SizedBox(height: 12),
            ActionButton(
              icon: LineAwesomeIcons.capsules_solid,
              title: 'Diagnósticos',
              subtitle: 'Encuentre sus diagnósticos',
              color: primaryColor,
              isDark: themeProvider.isDarkMode,
              showChevron: true,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(FadeThroughPageRoute(page: const DiagnosesPage()));
              },
            ),
            const SizedBox(height: 12),
            ActionButton(
              icon: LineAwesomeIcons.heartbeat_solid,
              title: 'Recomendaciones',
              subtitle: 'Consulte sus dudas',
              color: primaryColor,
              isDark: themeProvider.isDarkMode,
              showChevron: true,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(FadeThroughPageRoute(page: const EnfermedadesPage()));
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: textColor.withOpacity(0.3)),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
