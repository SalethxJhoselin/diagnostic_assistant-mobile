import 'package:asd/utils/treatment_utils.dart';
  


List<String> obtenerTratamientosParaHoy(List<Map<String, dynamic>> tratamientos) {
  final hoy = DateTime.now();
  final diaActual = DateTime.utc(hoy.year, hoy.month, hoy.day);
  final Map<DateTime, List<String>> eventosTratamiento = {};

  for (final t in tratamientos) {
    try {
      final rawFecha = t['consultations']?[0]?['consultation']?['consultationDate'];
      if (rawFecha == null) continue;
      final start = DateTime.parse(rawFecha);
      final dias = parseDuration(t['duration']);
      final frecuencia = t['frequencyValue'] ?? 1;
      final unidad = t['frequencyUnit'] ?? 'daily';
      final fechas = calcularFechasAplicacion(start, dias, frecuencia, unidad);

      for (final fecha in fechas) {
        final dia = DateTime.utc(fecha.year, fecha.month, fecha.day);
        eventosTratamiento.putIfAbsent(dia, () => []).add(t['description'] ?? '');
      }
    } catch (_) {
      continue;
    }
  }

  return eventosTratamiento[diaActual] ?? [];
}
