import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../utils/constantes.dart';

class AutenticacionServices {
  Future<String?> loginUsuario({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constantes.uri}/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final tokenElement = document.findAllElements('token').first;
        final token = tokenElement.text;
        return token;
      } else {
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Problemas con el servidor")),
      );
      return null;
    }
  }
}
