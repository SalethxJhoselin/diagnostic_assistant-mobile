import 'dart:convert';

import '../utils/constantes.dart';
import 'package:http/http.dart' as http;

class AtencionService {
  static Future<List<Map<String, dynamic>>> getAtenciones(int id) async {
    final response =
        await http.get(Uri.parse('${Constantes.uri}/attentions/user/$id'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> atenciones =
          data.map((e) => Map<String, dynamic>.from(e)).toList();

      return atenciones;
    } else {
      throw Exception('Failed to load atenciones');
    }
  }

  static Future<List<int>> downloadAttentionReport(int userId) async {
    final url = Uri.parse('${Constantes.uri}/attentions/export/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download PDF report');
    }
  }
}
