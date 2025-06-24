import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../services/patientService.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

  Future<void> updateUserData({String? email, int? phone}) async {
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    notifyListeners();
  }

  Future<bool> hasStoredToken() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      return false;
    }
    final isExpired = JwtDecoder.isExpired(token);
    return !isExpired;
  }

  Future<void> fetchAndSetPatientData() async {
    if (_token == null || _patientId == null) return;

    final data = await PatientService.getPatientById(patientId: _patientId!);

    if (data != null) {
      _name = data['name'];
      _aPaternal = data['aPaternal'];
      _aMaternal = data['aMaternal'];
      _sexo = data['sexo'];
      _birthDate = data['birthDate'];
      _phone = data['phone'];
      _email = data['email'];
      _ci = data['ci'];
      _organizationId = data['organizationId'];
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _organizations = [];

  List<Map<String, dynamic>> get organizations => _organizations;

  Future<void> loadUserFromToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      _token = token;
      final decodedToken = JwtDecoder.decode(token);
      _organizations = List<Map<String, dynamic>>.from(
        decodedToken['organizations'] ?? [],
      );
      notifyListeners();
    }
  }

  // Nuevo método para cargar la organización seleccionada
  void selectOrganization(String orgId) {
    final org = _organizations.firstWhere((o) => o['id'] == orgId);
    _organizationId = org['id'];
    _patientId = org['patientId'];
    _email = org['hostUser'];
    notifyListeners();

    _handleDeviceTokenRegistration(); // Llamar al método para FCM
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

  Future<void> _handleDeviceTokenRegistration() async {
    if (_patientId == null) return;

    try {
      String? fcmToken = await _firebaseMessaging.getToken();
      debugPrint('==== FCM token ====');
      debugPrint(fcmToken);

      if (fcmToken != null) {
        final success = await PatientService.registerDeviceToken(
          patientId: _patientId!,
          fcmToken: fcmToken,
        );
        if (!success) {
          debugPrint('Error al registrar el device token');
        }
      } else {
        debugPrint('No se pudo obtener el FCM token');
      }
    } catch (e) {
      debugPrint('Excepción al registrar device token: $e');
    }
  }
}
