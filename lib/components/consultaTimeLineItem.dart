import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Card.dart';
import 'infoItem.dart';

class ConsultaTimelineItem extends StatelessWidget {
  final Map<String, dynamic> consulta;
  final bool isFirst;
  final bool isLast;

  const ConsultaTimelineItem({
    super.key,
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
        Expanded(
          child: ProfileCard(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      child: Icon(Icons.medical_services, color: Colors.teal),
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
                InfoItem(
                  icon: Icons.help_outline,
                  label: 'Motivo',
                  value: consulta['motivo'] ?? 'No especificado',
                ),
                if (consulta['observaciones'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InfoItem(
                      icon: Icons.notes,
                      label: 'Observaciones',
                      value: consulta['observaciones'],
                    ),
                  ),
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
                                      InfoItem(
                                        icon: Icons.timelapse,
                                        label: 'Duración',
                                        value:
                                            tr['duration'] ?? 'No especificado',
                                      ),
                                      InfoItem(
                                        icon: Icons.repeat,
                                        label: 'Frecuencia',
                                        value:
                                            '${tr['frequencyValue']} ${tr['frequencyUnit']}',
                                      ),
                                      InfoItem(
                                        icon: Icons.list_alt,
                                        label: 'Instrucciones',
                                        value:
                                            tr['instructions'] ??
                                            'No especificado',
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
      ],
    );
  }
}
