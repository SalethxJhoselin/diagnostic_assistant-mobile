import 'package:asd/components/customAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/userProvider.dart';
import '../services/consulta_service.dart';
import '../components/Card.dart';
import '../components/emptyState.dart';

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  State<ConsultasPage> createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  List<Map<String, dynamic>> consultas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    try {
      final allConsultas = await ConsultaService.obtenerConsultas(context);
      final patientId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).patientId;
      final filtradas = allConsultas
          .where((c) => c['patientId'] == patientId)
          .toList();

      setState(() {
        consultas = filtradas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudieron cargar las consultas: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      appBar: const CustomAppBar(title1: 'Historial de Consultas'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : consultas.isEmpty
          ? const EmptyStateWidget(message: 'No tienes consultas registradas.')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: consultas
                    .map((consulta) => _buildConsultaCard(consulta))
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildConsultaCard(Map<String, dynamic> consulta) {
    final dateFormatted = _formatDate(consulta['consultationDate']);
    return ProfileCard(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              consulta['motivo'] ?? 'Motivo no disponible',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Fecha de consulta', dateFormatted),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Observaciones',
              consulta['observaciones'] ?? 'No disponible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No disponible';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (_) {
      return dateStr;
    }
  }
}
