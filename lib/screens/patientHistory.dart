import 'package:asd/components/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/Card.dart';
import '../components/DownloadHistoryButton.dart';
import '../components/consultaTimelineItem.dart';
import '../components/emptyState.dart';
import '../components/infoItem.dart';
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
      appBar: CustomAppBar(title1: 'Historial Clínico'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PatientHeader(patient: patient),
                  if (consultations.isEmpty)
                    const EmptyStateWidget()
                  else
                    const DownloadHistoryButton(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: consultations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final consulta = consultations[index];
                        return ConsultaTimelineItem(
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

    return ProfileCard(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
              InfoItem(
                icon: Icons.calendar_today,
                label: 'Nacimiento',
                value: '$birthDate ($age)',
              ),
              InfoItem(
                icon: Icons.phone,
                label: 'Teléfono',
                value: patient?['phone']?.toString() ?? 'No especificado',
              ),
              InfoItem(
                icon: Icons.email,
                label: 'Email',
                value: patient?['email'] ?? 'No especificado',
              ),
              InfoItem(
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