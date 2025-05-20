import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../components/customAppBar.dart';

class RecetasMedicasPage extends StatefulWidget {
  const RecetasMedicasPage({super.key});

  @override
  RecetasMedicasPageState createState() => RecetasMedicasPageState();
}

class RecetasMedicasPageState extends State<RecetasMedicasPage> {
  // Simulación de datos de recetas médicas
  final List<Map<String, String>> recetasMedicas = [
    {
      'fechaEmision': '2024-11-10',
      'medicamento': 'Ibuprofeno',
      'dosis': '200 mg',
      'frecuencia': 'Cada 8 horas',
      'duracion': '5 días',
      'instrucciones': 'Tomar después de las comidas'
    },
    {
      'fechaEmision': '2024-11-12',
      'medicamento': 'Amoxicilina',
      'dosis': '500 mg',
      'frecuencia': 'Cada 12 horas',
      'duracion': '7 días',
      'instrucciones': 'No interrumpir el tratamiento aunque se sienta mejor'
    },
    {
      'fechaEmision': '2024-11-14',
      'medicamento': 'Paracetamol',
      'dosis': '500 mg',
      'frecuencia': 'Cada 6 horas',
      'duracion': '3 días',
      'instrucciones': 'Tomar si hay fiebre o dolor'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Mis recetas médicas',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Color.fromARGB(255, 207, 230, 253),
        titlecolor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: recetasMedicas
                .map((receta) => buildRecetaCard(receta))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget buildRecetaCard(Map<String, String> receta) {
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
              receta['medicamento'] ?? '',
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
                buildInfoRow('Fecha de Emisión', receta['fechaEmision']),
                const Divider(),
                buildInfoRow('Frecuencia', receta['frecuencia']),
                const Divider(),
                buildInfoRow('Duración', receta['duracion']),
                const Divider(),
                buildInfoRow('Dosis', receta['dosis']),
                const Divider(),
                buildInfoRow('Instrucciones', receta['instrucciones']),
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
              color: Colors.black38),
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
