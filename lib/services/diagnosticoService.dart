import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class DiagnosticoService {
  static Future<List<Map<String, dynamic>>> getDiagnosticos(int id) async {
    final response =
        await http.get(Uri.parse('${Constantes.uri}/diagnosticos/user/$id'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> diagnosticos =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      return diagnosticos;
    } else {
      throw Exception('Failed to load diagnosticos');
    }
  }

  static Future<List<int>> downloadDiagnosticoReport(int userId) async {
    final url = Uri.parse('${Constantes.uri}/diagnosticos/export/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download PDF report');
    }
  }
}
