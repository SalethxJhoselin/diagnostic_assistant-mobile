import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _usuario;
  String? _nombre;
  String? _email;
  int? _id;
  List<String>? _permisos;

  String? get usuario => _usuario;
  String? get nombre => _nombre;
  String? get email => _email;
  int? get id => _id;
  List<String>? get permisos => _permisos;

  // Cargar usuario desde el token
  Future<void> loadUserFromToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decodedToken = JwtDecoder.decode(token);
      _id = decodedToken['id'];
      _usuario = decodedToken['usuario'];
      _nombre = decodedToken['nombre'];
      _email = decodedToken['email'];
      _permisos = List<String>.from(decodedToken['Permisos'] ?? []);
      notifyListeners();
    }
  }

  // Guardar token y cargar datos del usuario
  Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
    await loadUserFromToken();
  }

  // Limpiar token y datos de usuario
  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
    _id = null;
    _usuario = null;
    _nombre = null;
    _email = null;
    _permisos = null;
    notifyListeners();
  }
}
