import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constantes.dart'; // Asegúrate de tener la URL base y otros parámetros
import 'package:provider/provider.dart';
import '../providers/userProvider.dart'; // Importamos el UserProvider

class AppointmentService {
  // Obtener las horas de atención para una organización específica
  static Future<List<Map<String, dynamic>>> obtenerHorasAtencionPorOrganizacion(
    String organizationId,
  ) async {
    final uri = Uri.parse(
      '${Constantes.uri}/attention-hour/organization/$organizationId',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        throw Exception(
          'Error al cargar las horas de atención para la organización: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Crear una nueva cita (modificado para no depender del UserProvider directamente)
  static Future<Map<String, dynamic>> crearCita({
    required String date,
    required String startTime,
    required String endTime,
    required String patientId,
    required String organizationId,
  }) async {
    final uri = Uri.parse('${Constantes.uri}/appointments');

    final body = {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'patientId': patientId,
      'organizationId': organizationId,
    };

    print('Cuerpo enviado: ${json.encode(body)}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Error al crear la cita: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Obtener todas las citas
  static Future<List<Map<String, dynamic>>> obtenerCitas() async {
    final uri = Uri.parse(
      '${Constantes.uri}/appointments',
    ); // URL para obtener todas las citas

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Error al obtener las citas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Obtener una cita por ID
  static Future<Map<String, dynamic>> obtenerCitaPorId(String citaId) async {
    final uri = Uri.parse(
      '${Constantes.uri}/appointments/$citaId',
    ); // URL para obtener una cita por ID

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body); // Devuelve los detalles de la cita
      } else {
        throw Exception('Error al obtener la cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Obtener citas por organización
  static Future<List<Map<String, dynamic>>> obtenerCitasPorOrganizacion(
    String organizationId,
  ) async {
    final uri = Uri.parse(
      '${Constantes.uri}/appointments?organizationid=$organizationId',
    ); // URL para obtener citas por organización

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
          'Error al obtener las citas por organización: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerCitasPorPaciente(
    String patientId,
  ) async {
    final uri = Uri.parse(
      '${Constantes.uri}/appointments?patientId=$patientId',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
          'Error al obtener las citas: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }
}
