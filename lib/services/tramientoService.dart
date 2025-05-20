import 'dart:convert';

import '../utils/constantes.dart';
import 'package:http/http.dart' as http;

class TratamientoService {
  static Future<List<Map<String, dynamic>>> getTratamientos(int id) async {
    final response =
        await http.get(Uri.parse('${Constantes.uri}/tratamientos/user/$id'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> tratamientos =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      return tratamientos;
    } else {
      throw Exception('Failed to load tratamientos');
    }
  }

  static Future<List<int>> downloadTratamientoReport(int userId) async {
    final url = Uri.parse('${Constantes.uri}/tratamientos/export/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download PDF report');
    }
  }
}
