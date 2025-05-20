import 'dart:convert';

import '../utils/constantes.dart';
import 'package:http/http.dart' as http;

class LaboratorioService {
  static Future<List<Map<String, dynamic>>> getLaboratorios(int id) async {
    final response =
        await http.get(Uri.parse('${Constantes.uri}/laboratorios/user/3'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> laboratorios =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      return laboratorios;
    } else {
      throw Exception('Failed to load laboratorios');
    }
  }

  static Future<List<int>> downloadLaboratorioReport(int userId) async {
    final url = Uri.parse('${Constantes.uri}/laboratorios/export/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download PDF report');
    }
  }
}
