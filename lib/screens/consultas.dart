import 'dart:io';

import 'package:asd/services/atencionService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../components/customAppBar.dart';
import '../providers/userProvider.dart';

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  ConsultasPageState createState() => ConsultasPageState();
}

class ConsultasPageState extends State<ConsultasPage> {
  late Future<List<Map<String, dynamic>>> _futureAtenciones;

  @override
  void initState() {
    super.initState();
    _futureAtenciones = _loadAtenciones();
  }

  Future<List<Map<String, dynamic>>> _loadAtenciones() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.patientId;

    if (userId != null) {
      try {
        return await AtencionService.getAtenciones(int.parse(userId));
      } catch (e) {
        debugPrint('Error al cargar atenciones: $e');
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
        final bytes = await AtencionService.downloadAttentionReport(int.parse(userId));
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/reporte_atencioness_$userId.pdf';
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
    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Mis Consultas',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureAtenciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron consultas'),
            );
          }

          final atenciones = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 207, 230, 253),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      LineAwesomeIcons.download_solid,
                      color: Colors.black,
                    ),
                    onPressed: _downloadReport,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: atenciones
                        .map((atencion) => buildConsultaCard(atencion))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildConsultaCard(Map<String, dynamic> consulta) {
    String formatFecha(List<dynamic>? fecha) {
      if (fecha != null && fecha.length == 3) {
        final date = DateTime(fecha[0], fecha[1], fecha[2]);
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return 'Desconocido';
    }

    String formatHora(List<dynamic>? hora) {
      if (hora != null && hora.length == 3) {
        final hours = hora[0].toString().padLeft(2, '0');
        final minutes = hora[1].toString().padLeft(2, '0');
        final seconds = hora[2].toString().padLeft(2, '0');
        return '$hours:$minutes:$seconds'; // Hora en formato HH:mm:ss
      }
      return 'Desconocido';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 68, 85, 102),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    consulta['motivo_consulta'] ?? '',
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
                buildInfoRow('Fecha', formatFecha(consulta['fecha_atencion'])),
                const Divider(),
                buildInfoRow('Hora', formatHora(consulta['hora_atencion'])),
                const Divider(),
                buildInfoRow('Recomendaciones', consulta['recomendaciones']),
                const Divider(),
                buildEstadoChip('Estado', consulta['estado']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: Colors.black38,
          ),
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEstadoChip(String title, String? estado) {
    Color estadoColor = Colors.grey;

    switch (estado) {
      case 'Finalizado':
        estadoColor = Colors.green;
        break;
      case 'Pendiente':
        estadoColor = Colors.orange;
        break;
      case 'Cancelado':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: Colors.black38,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: estadoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            estado ?? 'Desconocido',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: estadoColor,
            ),
          ),
        ),
      ],
    );
  }
}
