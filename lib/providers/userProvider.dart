import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? _patientId;
  String? _name;
  String? _aPaternal;
  String? _aMaternal;
  String? _sexo;
  String? _birthDate;
  int? _phone;
  String? _email;
  int? _ci;
  String? _organizationId;

  // Getters
  String? get token => _token;
  String? get patientId => _patientId;
  String? get name => _name;
  String? get aPaternal => _aPaternal;
  String? get aMaternal => _aMaternal;
  String? get sexo => _sexo;
  String? get birthDate => _birthDate;
  int? get phone => _phone;
  String? get email => _email;
  int? get ci => _ci;
  String? get organizationId => _organizationId;

  // datos para biometría
  Future<void> saveCredentials(String email, int ci) async {
    await _storage.write(key: 'saved_email', value: email);
    await _storage.write(key: 'saved_ci', value: ci.toString());
  }

  Future<Map<String, String>?> getCredentials() async {
    final email = await _storage.read(key: 'saved_email');
    final ci = await _storage.read(key: 'saved_ci');
    return (email != null && ci != null) ? {'email': email, 'ci': ci} : null;
  }

  Future<bool> hasStoredToken() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      return false;
    }
    final isExpired = JwtDecoder.isExpired(token);
    return !isExpired;
  }

  // Cargar usuario desde el token
  Future<void> loadUserFromToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      _token = token; // Asegúrate de asignar el token recuperado
      final decodedToken = JwtDecoder.decode(
        token,
      ); // Usa el token recién recuperado

      // Extraer datos del paciente
      final patientData = decodedToken['patient'];
      _patientId = patientData['id'];
      _name = patientData['name'];
      _aPaternal = patientData['aPaternal'];
      _aMaternal = patientData['aMaternal'];
      _sexo = patientData['sexo'];
      _birthDate = patientData['birthDate'];
      _phone = patientData['phone'];
      _email = patientData['email'];
      _ci = patientData['ci'];
      _organizationId = patientData['organizationId'];

      notifyListeners();
    }
  }

  // Guardar token y cargar datos del usuario
  Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
    await loadUserFromToken();
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'token');
    return token != null && !JwtDecoder.isExpired(token);
  }
}
