import 'package:asd/components/customAppBar.dart';
import 'package:asd/screens/enfermedades.dart';
import 'package:flutter/material.dart';

import '../services/consulta_service.dart'; // Asegúrate de importar el servicio de consultas

class ConsultasPage extends StatefulWidget {
  const ConsultasPage({super.key});

  @override
  _ConsultasPageState createState() => _ConsultasPageState();
}

class _ConsultasPageState extends State<ConsultasPage> {
  // Variable para almacenar las consultas
  List<Map<String, dynamic>> consultas = [];

  @override
  void initState() {
    super.initState();
    // Cargar las consultas cuando la página se inicie
    _loadConsultas();
  }

  // Función para cargar las consultas
  void _loadConsultas() async {
    try {
      final consultasData = await ConsultaService.obtenerConsultas(context);
      setState(() {
        consultas = consultasData;
      });
    } catch (e) {
      // Manejo de errores
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudieron cargar las consultas: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
        255,
        5,
        5,
        5,
      ), // Fondo suave y claro para la página
      appBar: const CustomAppBar(
        title1: 'Consultas del Paciente',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: consultas.isEmpty
                ? [
                    Center(child: CircularProgressIndicator()),
                  ] // Mostrar loading si no hay datos
                : consultas
                      .map((registro) => buildConsultaCard(registro))
                      .toList(),
          ),
        ),
      ),
    );
  }

  // Método para construir la tarjeta de cada consulta
  Widget buildConsultaCard(Map<String, dynamic> consulta) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              color: Color(0xFF3E4A59), // Color de fondo de la cabecera
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
            ),
            child: Text(
              consulta['motivo'] ?? 'Motivo no disponible',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Observaciones', consulta['observaciones']),
                const Divider(),
                buildInfoRow('Fecha de Consulta', consulta['consultationDate']),
                const Divider(),
                buildMoreDetailsButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar cada fila de información (motivo, observaciones, etc.)
  Widget buildInfoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            color: Colors.black45,
          ),
        ),
        Expanded(
          child: Text(
            value ?? '',
            style: const TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // Método para mostrar el botón de más detalles (si quieres expandir la consulta)
  Widget buildMoreDetailsButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Navegar a la pantalla de Enfermedades
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EnfermedadesPage(), // Redirigir a la pantalla de Enfermedades
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
            Text('Ver más detalles', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
