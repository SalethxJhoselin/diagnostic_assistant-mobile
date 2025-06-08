import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../utils/constantes.dart';

class HistoryService {
  static Future<Map<String, dynamic>?> getPatientHistory({
    required String patientId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${Constantes.uri}/consultations/patient/$patientId/history'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error [${response.statusCode}] al obtener historial');
        return null;
      }
    } catch (e) {
      print('Excepción al obtener historial: $e');
      return null;
    }
  }

  static Future<void> downloadMedicalHistoryReport(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patientId = userProvider.patientId;
    final uri = Uri.parse(
      '${Constantes.uri}/reportHistory/patient/$patientId/history',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (!contentType!.contains('application/pdf')) {
          throw Exception('Respuesta no es un archivo PDF válido');
        }

        String fileName = 'historial-medico-${_getFormattedDate()}.pdf';
        final disposition = response.headers['content-disposition'];
        if (disposition != null) {
          final match = RegExp(r'filename="(.+)"').firstMatch(disposition);
          if (match != null) fileName = match.group(1)!;
        }

        if (response.bodyBytes.isEmpty) {
          throw Exception('El archivo PDF recibido está vacío.');
        }

        String filePath;
        if (Platform.isAndroid) {
          filePath = await _saveToDownloadsAndroid(
            response.bodyBytes,
            fileName,
          );
        } else {
          throw Exception('Plataforma no soportada');
        }

        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          throw Exception('No se pudo abrir el PDF: ${result.message}');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Error al descargar el historial: ${errorBody['message'] ?? 'Desconocido'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> _saveToDownloadsAndroid(
    List<int> bytes,
    String fileName,
  ) async {
    // Pedir permiso completo para gestionar almacenamiento (Android 11+)
    PermissionStatus status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        throw Exception(
          'Por favor habilite el permiso de almacenamiento completo en la configuración.',
        );
      }
      throw Exception(
        'Se requiere permiso para acceder a la carpeta de Descargas.',
      );
    }

    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!await file.exists() || await file.length() == 0) {
        throw Exception('El archivo PDF no se guardó correctamente.');
      }

      return filePath;
    } catch (e) {
      return await _saveWithSAF(bytes, fileName);
    }
  }

  static Future<String> _saveWithSAF(List<int> bytes, String fileName) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Seleccione dónde guardar el reporte',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      throw Exception('El usuario canceló la selección de ubicación.');
    }

    final file = File(result);
    await file.writeAsBytes(bytes);

    if (!await file.exists() || await file.length() == 0) {
      throw Exception('El archivo PDF no se guardó correctamente usando SAF.');
    }
    return result;
  }

  static String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year.toString().substring(2)}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
