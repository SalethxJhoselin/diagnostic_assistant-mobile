import '../utils/constantes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgramingMedicalsServices {
  static Future<List<Map<String, dynamic>>> getProgramings() async {
    final response =
        await http.get(Uri.parse('${Constantes.uri}/doctor-schedule'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> result = [];

      // Agrupar los horarios por médico
      for (var doctor in data) {
        String doctorName = doctor['person']['nombre'];
        List<Map<String, dynamic>> horarios = [];

        for (var schedule in doctor['horarios']) {
          for (var fecha in schedule['fechas']) {
            horarios.add({
              'startTime': schedule['startTime'],
              'endTime': schedule['endTime'],
              'service': schedule['service']['nombre'],
              'duracion': schedule['service']['duracion'],
              'serviceId': schedule['service']['id'],
              'fecha': fecha,
            });
          }
        }

        result.add({
          'doctorNombre': doctorName,
          'horarios': horarios,
        });
      }

      return result;
    } else {
      throw Exception('Failed to load programing');
    }
  }

  static Future<List<Map<String, dynamic>>> getInsureds() async {
    final response = await http.get(Uri.parse('${Constantes.uri}/insureds'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      List<Map<String, dynamic>> insureds =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      return insureds;
    } else {
      throw Exception('Failed to load insureds');
    }
  }

  static Future<void> reservarCita({
    required int personaId,
    required int serviceId,
    required String horaReserva,
    required String fecha,
    String? estado,
    String? comentario,
    required int aseguradoId,
  }) async {
    final url = Uri.parse('${Constantes.uri}/reservas');
    final body = {
      "personaId": personaId,
      "serviceId": serviceId,
      "horaReserva": horaReserva,
      "fecha": fecha,
      "estado": estado ?? "pendiente",
      "comentario": comentario ?? "..",
      "aseguradoId": aseguradoId,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al reservar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
