import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../components/customAppBar.dart';
import '../providers/userProvider.dart';
import '../services/tramientoService.dart';

class TratamientosPage extends StatefulWidget {
  const TratamientosPage({super.key});

  @override
  TratamientosPageState createState() => TratamientosPageState();
}

class TratamientosPageState extends State<TratamientosPage> {
  late Future<List<Map<String, dynamic>>> _futureTratamientos;

  @override
  void initState() {
    super.initState();
    _futureTratamientos = _loadTratamientos();
  }

  Future<List<Map<String, dynamic>>> _loadTratamientos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.id;

    if (userId != null) {
      try {
        return await TratamientoService.getTratamientos(userId);
      } catch (e) {
        debugPrint('Error al cargar tratamientos: $e');
        return [];
      }
    } else {
      debugPrint('El usuario no está autenticado.');
      return [];
    }
  }

  Future<void> _downloadReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.id;

    if (userId != null) {
      try {
        final bytes =
            await TratamientoService.downloadTratamientoReport(userId);
        final directory = await getExternalStorageDirectory();
        final filePath = '${directory!.path}/reporte_tratamientos_$userId.pdf';
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
        title1: 'Mis Tratamientos',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTratamientos,
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
              child: Text('No se encontraron tratamientos'),
            );
          }

          final tratamientos = snapshot.data!;
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
                    children: tratamientos
                        .map((tratamiento) => buildTratamientoCard(tratamiento))
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

  Widget buildTratamientoCard(Map<String, dynamic> tratamiento) {
    String formatFecha(List<dynamic>? fecha) {
      if (fecha != null && fecha.length == 3) {
        final date = DateTime(fecha[0], fecha[1], fecha[2]);
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return 'Desconocido';
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          if (!isDarkMode)
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
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]
                  : const Color.fromARGB(255, 68, 85, 102),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tratamiento['descripcion'] ?? '',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LineAwesomeIcons.angle_right_solid,
                    color: isDarkMode ? Colors.white : Colors.white,
                  ),
                  onPressed: () {
                    // Acción al presionar el ícono
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Fecha de Inicio',
                    formatFecha(tratamiento['fecha_inicio'])),
                const Divider(),
                buildInfoRow(
                    'Fecha Fin', formatFecha(tratamiento['fecha_fin'])),
                const Divider(),
                buildEstadoChip('Estado', tratamiento['estado']),
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

  Widget buildEstadoChip(String title, String? estado) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: isDarkMode ? Colors.white70 : Colors.black38,
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
