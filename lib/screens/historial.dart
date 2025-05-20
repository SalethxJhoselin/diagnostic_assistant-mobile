import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../components/customAppBar.dart';

class HistorialClinicoPage extends StatefulWidget {
  const HistorialClinicoPage({super.key});

  @override
  HistorialClinicoPageState createState() => HistorialClinicoPageState();
}

class HistorialClinicoPageState extends State<HistorialClinicoPage> {
  // Simulación de datos del historial clínico
  final List<Map<String, String>> historialClinico = [
    {
      'servicio': 'Consulta General',
      'nombreAsegurado': 'Jhon Said Andia Merino',
      'hora': '10:30 AM',
      'estado': 'Finalizado',
    },
    {
      'servicio': 'Radiografía',
      'nombreAsegurado': 'Jhon Said Andia Merino',
      'hora': '12:15 PM',
      'estado': 'Pendiente',
    },
    {
      'servicio': 'Chequeo Oftalmológico',
      'nombreAsegurado': 'Jhon Said Andia Merino',
      'hora': '09:00 AM',
      'estado': 'Finalizado',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Historial Clínico',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: historialClinico
                .map((registro) => buildHistorialCard(registro))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildHistorialCard(Map<String, String> registro) {
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
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 68, 85, 102),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Text(
              registro['servicio'] ?? '',
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
                buildInfoRow('Nombre Asegurado', registro['nombreAsegurado']),
                const Divider(),
                buildInfoRow('Hora', registro['hora']),
                const Divider(),
                buildEstadoChip('Estado', registro['estado']),
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
