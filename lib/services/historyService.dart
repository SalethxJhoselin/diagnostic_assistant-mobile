import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class HistoryService {
  static Future<Map<String, dynamic>?> getPatientHistory({
    required String patientId,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '${Constantes.uri}/consultations/patient/$patientId/history',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error [${response.statusCode}] al obtener historial');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener historial: $e');
      return null;
    }
  }
}
