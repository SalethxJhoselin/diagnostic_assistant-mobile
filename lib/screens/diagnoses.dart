import 'package:flutter/material.dart';

import '../components/customAppBar.dart';
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
    _futureDiagnoses = DiagnosticoService.getDiagnosticosFromContext(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: const CustomAppBar(
        title1: 'Mis Diagnósticos',
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: diagnosticos.map((diagnostico) {
                return buildDiagnosticoCard(diagnostico);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget buildDiagnosticoCard(Map<String, dynamic> diagnostico) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final id = diagnostico['id'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
            child: Text(
              diagnostico['name'] ?? 'Sin nombre',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Descripción', diagnostico['description']),
                const Divider(),
                buildInfoRow(
                  'Fecha de Creación',
                  _formatFecha(diagnostico['creationDate']),
                ),
                const Divider(),
                const Text(
                  'Consultas Asociadas:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...?diagnostico['consultations']?.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow(
                          'Fecha',
                          _formatFecha(c['consultation']['consultationDate']),
                        ),
                        buildInfoRow('Motivo', c['consultation']['motivo']),
                        buildInfoRow(
                          'Paciente',
                          c['consultation']['patient']['name'],
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(String? fechaISO) {
    if (fechaISO == null) return 'No disponible';
    try {
      final date = DateTime.parse(fechaISO);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return 'Fecha inválida';
    }
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
            value ?? 'No disponible',
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
