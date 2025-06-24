import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class PatientService {
  static Future<Map<String, dynamic>?> getPatientById({
    required String patientId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Constantes.uri}/patients/$patientId'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<bool> updatePatientByCi({
    required int ci,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${Constantes.uri}/patients/by-ci/$ci'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al actualizar paciente: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Excepción al actualizar paciente: $e');
      return false;
    }
  }

  static Future<bool> registerDeviceToken({
    required String patientId,
    required String fcmToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.uri}/patients/register-device-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'patientId': patientId, 'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        print('Dispositivo registrado correctamente');
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        final errorMsg = responseData['msg'] ?? 'Error desconocido';
        print('Error: $errorMsg');
        return false;
      }
    } catch (e) {
      print('Error de conexion: $e');
      return false;
    }
  }
}
