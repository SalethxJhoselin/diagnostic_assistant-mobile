import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../services/historyService.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  Map<String, dynamic>? historyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final data = await HistoryService.getPatientHistory(
      patientId: userProvider.patientId!,
      token: userProvider.token!,
    );

    if (mounted) {
      setState(() {
        historyData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final patient = historyData?['patient'];
    final consultations = historyData?['consultations'] ?? [];

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(
        title: const Text('Historial Clínico'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con información del paciente
                  _PatientHeader(patient: patient),
                  const SizedBox(height: 8),

                  // Lista de consultas
                  if (consultations.isEmpty)
                    _buildEmptyState(colorScheme, theme)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: consultations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final consulta = consultations[index];
                          return _ConsultaTimelineItem(
                            consulta: consulta,
                            isFirst: index == 0,
                            isLast: index == consultations.length - 1,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay registros médicos',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final Map<String, dynamic>? patient;

  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final birthDate = patient?['birthDate'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(patient?['birthDate']))
        : 'No especificado';
    final age = patient?['birthDate'] != null
        ? '${DateTime.now().difference(DateTime.parse(patient?['birthDate'])).inDays ~/ 365} años'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 30, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient?['name'] ?? ''} ${patient?['aPaternal'] ?? ''} ${patient?['aMaternal'] ?? ''}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CI: ${patient?['ci'] ?? 'No especificado'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PatientDetailItem(
                icon: Icons.calendar_today,
                label: 'Nacimiento',
                value: '$birthDate ($age)',
              ),
              _PatientDetailItem(
                icon: Icons.phone,
                label: 'Teléfono',
                value: patient?['phone']?.toString() ?? 'No especificado',
              ),
              _PatientDetailItem(
                icon: Icons.email,
                label: 'Email',
                value: patient?['email'] ?? 'No especificado',
              ),
              _PatientDetailItem(
                icon: Icons.people,
                label: 'Sexo',
                value: patient?['sexo'] ?? 'No especificado',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PatientDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsultaTimelineItem extends StatelessWidget {
  final Map<String, dynamic> consulta;
  final bool isFirst;
  final bool isLast;

  const _ConsultaTimelineItem({
    required this.consulta,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fecha = DateTime.parse(consulta['consultationDate']);
    final format = DateFormat('EEE, d MMM y - hh:mm a');
    final profesional =
        consulta['user']?['email'] ?? 'Profesional no especificado';
    final tratamientos = consulta['treatments'] ?? [];
    final diagnosticos = consulta['diagnoses'] ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea de tiempo
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 12,
                color: colorScheme.outline.withOpacity(0.2),
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 3),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 12,
                color: colorScheme.outline.withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Contenido de la consulta
        Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(18),
            elevation: 1,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha y profesional
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format.format(fecha),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profesional,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Motivo
                  _InfoSection(
                    icon: Icons.help_outline,
                    title: 'Motivo de consulta',
                    content: consulta['motivo'] ?? 'No especificado',
                  ),

                  // Observaciones
                  if (consulta['observaciones'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _InfoSection(
                        icon: Icons.notes,
                        title: 'Observaciones',
                        content: consulta['observaciones'],
                      ),
                    ),

                  // Diagnósticos
                  if (diagnosticos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.assignment,
                                size: 20,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Diagnósticos',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...diagnosticos.map((d) {
                            final diag = d['diagnosis'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    diag['name'],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (diag['description'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8,
                                        top: 6,
                                      ),
                                      child: Text(
                                        diag['description'],
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                  // Tratamientos
                  if (tratamientos.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medication,
                                size: 20,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tratamientos',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...tratamientos.map((t) {
                            final tr = t['treatment'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr['description'],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      top: 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _TreatmentDetail(
                                          label: 'Duración',
                                          value: tr['duration'],
                                        ),
                                        _TreatmentDetail(
                                          label: 'Frecuencia',
                                          value:
                                              '${tr['frequencyValue']} ${tr['frequencyUnit']}',
                                        ),
                                        _TreatmentDetail(
                                          label: 'Instrucciones',
                                          value: tr['instructions'],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TreatmentDetail extends StatelessWidget {
  final String label;
  final String? value;

  const _TreatmentDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value ?? 'No especificado',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
