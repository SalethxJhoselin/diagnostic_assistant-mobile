import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class PatientService {
  static Future<Map<String, dynamic>?> getPatientById({
    required String patientId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Constantes.uri}/patients/$patientId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error al obtener paciente: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener paciente: $e');
      return null;
    }
  }
}
