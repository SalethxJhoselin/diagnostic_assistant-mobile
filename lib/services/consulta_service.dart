import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart'; // Asegúrate de tener el provider para obtener el userId
import '../utils/constantes.dart'; // Asegúrate de tener las constantes necesarias

class ConsultaService {
  // Método para obtener las consultas de un paciente
  static Future<List<Map<String, dynamic>>> obtenerConsultas(
    BuildContext context,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patientId = userProvider.patientId;

    // Creamos la URL dinámica con el patientId
    final uri = Uri.parse('${Constantes.uri}/consultations/patient/$patientId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        // Devolvemos una lista de consultas con la estructura adecuada
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
          'Error al cargar las consultas: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }
}
