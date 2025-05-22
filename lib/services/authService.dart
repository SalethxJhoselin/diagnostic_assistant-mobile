import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constantes.dart';

class AutenticacionServices {
  Future<String?> loginUsuario({
    required BuildContext context,
    required String email,
    required int ci,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.uri}/auth/login/patient'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'ci': ci}),
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData.containsKey('access_token')) {
          return responseData['access_token']; // Token válido.
        } else if (responseData.containsKey('msg')) {
          // Mostrar mensaje de error del backend (ej: "paciente no existe").
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(responseData['msg'])));
          return null;
        }
      } else {
        // Otros códigos de estado (ej: 400, 500).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      return null;
    }
  }
}
