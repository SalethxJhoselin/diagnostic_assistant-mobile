import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../components/customAppBar.dart';
import '../providers/userProvider.dart';
import '../services/diagnosticoService.dart';

class DiagnosesPage extends StatefulWidget {
  const DiagnosesPage({super.key});

  @override
  DiagnosesPageState createState() => DiagnosesPageState();
}

class DiagnosesPageState extends State<DiagnosesPage> {
  late Future<List<Map<String, dynamic>>> _futureDiagnoses;

  @override
  void initState() {
    super.initState();
    _futureDiagnoses = _loadDiagnoses();
  }

  Future<List<Map<String, dynamic>>> _loadDiagnoses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.patientId;

    if (userId != null) {
      try {
        return await DiagnosticoService.getDiagnosticos(int.parse(userId));
      } catch (e) {
        debugPrint('Error al cargar diagnósticos: $e');
        return [];
      }
    } else {
      debugPrint('El usuario no está autenticado.');
      return [];
    }
  }

  Future<void> _downloadReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.patientId;

    if (userId != null) {
      try {
        final bytes = await DiagnosticoService.downloadDiagnosticoReport(int.parse(userId));
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/reporte_diagnosticos_$userId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reporte guardado en: $filePath'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar el reporte: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El usuario no está autenticado.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: const CustomAppBar(
        title1: 'Mis Diagnósticos',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Colors.teal,
        titlecolor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureDiagnoses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron diagnósticos'));
          }

          final diagnosticos = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          LineAwesomeIcons.download_solid,
                          color: Colors.white,
                        ),
                        onPressed: _downloadReport,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...diagnosticos.map((diagnostico) => buildDiagnosticoCard(diagnostico)).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDiagnosticoCard(Map<String, dynamic> diagnostico) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String formatFecha(List<dynamic>? fecha) {
      if (fecha != null && fecha.length == 3) {
        final date = DateTime(fecha[0], fecha[1], fecha[2]);
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return 'Desconocido';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    diagnostico['diagnostico'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LineAwesomeIcons.angle_right_solid,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Fecha', formatFecha(diagnostico['fecha'])),
                const Divider(),
                buildInfoRow('Especialidad', diagnostico['especialidad']),
                const Divider(),
                buildInfoRow('Médico', diagnostico['medico']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String? value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: isDarkMode ? Colors.white70 : Colors.black38,
          ),
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12.0,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
