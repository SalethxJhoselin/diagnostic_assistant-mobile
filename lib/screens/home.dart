import 'package:asd/components/wabeClipper.dart';
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

import '../components/Card.dart';
import '../components/fadeThroughPageRoute.dart';
import '../providers/userProvider.dart';
import '../services/tramientoService.dart';

// Importa tus pantallas y componentes aquí...

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días';
    if (hour < 18) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Colores adaptativos que cambian con el tema
    final primaryColor = colorScheme.primary;
    final primaryContainer = colorScheme.primaryContainer;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;
    final cardColor = colorScheme.surfaceVariant;

    return Scaffold(
      backgroundColor: cardColor.withOpacity(0.1),
      body: CustomScrollView(
        slivers: [
          // AppBar personalizado con efecto de onda
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: DoubleWaveClipper(),
                child: Container(
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
            ),
          ),

          // Contenido principal
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Encabezado con saludo y perfil
                _buildHeader(context, onSurfaceColor, primaryColor),

                // Tarjeta de próximas citas
                _buildAppointmentsCard(context, surfaceColor, onSurfaceColor),

                // Sección de acciones principales
                _buildMainActionsSection(primaryColor, onSurfaceColor),

                // Sección de servicios
                _buildServicesSection(primaryColor, onSurfaceColor),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
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
          const SizedBox(height: 16),
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
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
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
            _buildActionCard(
              'Reservar Cita',
              LineAwesomeIcons.notes_medical_solid,
              const ReservarCitasPage(),
              primaryColor,
              textColor,
            ),
            _buildActionCard(
              'Historial Clínico',
              LineAwesomeIcons.file_medical_solid,
              const PatientHistoryPage(),
              primaryColor,
              textColor,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Widget page,
    Color primaryColor,
    Color textColor,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, FadeThroughPageRoute(page: page)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(Color primaryColor, Color textColor) {
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
            _buildServiceItem(
              LineAwesomeIcons.brain_solid,
              'Tratamientos',
              'Servicios de psicología',
              const TratamientosPage(),
              primaryColor,
              textColor,
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              LineAwesomeIcons.user_md_solid,
              'Consulta Médica',
              'Encuentre sus consultas',
              const ConsultasPage(),
              primaryColor,
              textColor,
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              LineAwesomeIcons.capsules_solid,
              'Diagnósticos',
              'Encuentre sus diagnósticos',
              const DiagnosesPage(),
              primaryColor,
              textColor,
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              LineAwesomeIcons.heartbeat_solid,
              'Recomendaciones',
              'Consulte sus dudas',
              const EnfermedadesPage(),
              primaryColor,
              textColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem(
    IconData icon,
    String title,
    String subtitle,
    Widget page,
    Color primaryColor,
    Color textColor,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, FadeThroughPageRoute(page: page)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
            ],
          ),
        ),
      ),
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
            const SizedBox(height: 8),
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
