import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../utils/constantes.dart';

class TratamientoService {
  static Future<List<Map<String, dynamic>>> getTratamientosFromContext(
      BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patientId = userProvider.patientId;
    final organizationId = userProvider.organizationId;

    if (patientId == null || organizationId == null) {
      throw Exception('El usuario no está autenticado o falta información.');
    }

    final uri = Uri.parse(
      '${Constantes.uri}/treatments/by-pat-org?patId=$patientId&orgId=$organizationId&include=true',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Error al cargar tratamientos');
    }
  }

  static Future<List<int>> downloadTratamientoReport(
      BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patientId = userProvider.patientId;

    if (patientId == null) {
      throw Exception('No se puede descargar el reporte sin ID de paciente.');
    }

    final url =
        Uri.parse('${Constantes.uri}/tratamientos/export/$patientId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al descargar el reporte PDF');
    }
  }
}
