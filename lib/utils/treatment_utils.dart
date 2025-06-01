
List<DateTime> calcularFechasAplicacion(DateTime inicio, int duracionDias, int freq, String unidad) {
  final fechas = <DateTime>[];
  final fin = inicio.add(Duration(days: duracionDias));
  Duration intervalo;
  switch (unidad) {
    case 'daily':
      intervalo = Duration(days: (1 / freq).round());
      break;
    case 'weekly':
      intervalo = Duration(days: (7 / freq).round());
      break;
    default:
      intervalo = const Duration(days: 1);
  }
  DateTime actual = inicio;
  while (actual.isBefore(fin)) {
    fechas.add(actual);
    actual = actual.add(intervalo);
  }
  return fechas;
}

int parseDuration(String? d) {
  if (d == null) return 7;
  final lower = d.toLowerCase();
  if (lower.contains('semana')) {
    final n = int.tryParse(lower.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    return n * 7;
  } else if (lower.contains('mes')) {
    final n = int.tryParse(lower.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    return n * 30;
  }
  return 7;
}
