import 'package:asd/utils/treatment_utils.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/customAppBar.dart';
import '../components/reportFormScreen.dart';
import '../services/tramientoService.dart';

class TratamientosPage extends StatefulWidget {
  const TratamientosPage({super.key});

  @override
  TratamientosPageState createState() => TratamientosPageState();
}

class TratamientosPageState extends State<TratamientosPage> {
  late Future<List<Map<String, dynamic>>> _futureTratamientos;
  final Set<String> _expandedTratamientos = {};
  CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<DateTime, List<String>> eventosTratamiento = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureTratamientos = TratamientoService.getTratamientosFromContext(
      context,
    );
  }

  Future<void> _downloadCustomReport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await TratamientoService.downloadCustomTreatmentReport(
        context,
        startDate: null,
        endDate: null,
        frequencyUnit: null,
        minApplications: null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado en Descargas y abierto exitosamente'),
        ),
      );
    } catch (e) {
      if (e.toString().contains('noAppToOpenFile')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reporte guardado en Descargas, pero no se pudo abrir. Por favor instale un visor de PDF.',
            ),
          ),
        );
      } else if (e.toString().contains('canceló la selección')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La generación del reporte fue cancelada.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el reporte: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generarEventos(List<Map<String, dynamic>> tratamientos) {
    eventosTratamiento.clear();
    for (final t in tratamientos) {
      try {
        final rawFecha =
            t['consultations']?[0]?['consultation']?['consultationDate'];
        if (rawFecha == null) continue;
        final start = DateTime.parse(rawFecha);
        final dias = parseDuration(t['duration']);
        final frecuencia = t['frequencyValue'] ?? 1;
        final unidad = t['frequencyUnit'] ?? 'daily';
        final fechas = calcularFechasAplicacion(
          start,
          dias,
          frecuencia,
          unidad,
        );

        for (final fecha in fechas) {
          final dia = DateTime.utc(fecha.year, fecha.month, fecha.day);
          eventosTratamiento
              .putIfAbsent(dia, () => [])
              .add(t['description'] ?? '');
        }
      } catch (_) {
        continue;
      }
    }
  }

  List<String> _getEventosParaDia(DateTime dia) {
    return eventosTratamiento[DateTime.utc(dia.year, dia.month, dia.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: const CustomAppBar(
        title1: 'Mis Tratamientos',
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Colors.teal,
        titlecolor: Colors.white,
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureTratamientos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No se encontraron tratamientos'),
                );
              }

              final tratamientos = snapshot.data!;
              _generarEventos(tratamientos);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TableCalendar<String>(
                        firstDay: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selected, focused) {
                          setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.week: 'Semana',
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.teal[200],
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                        ),
                        eventLoader: _getEventosParaDia,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_selectedDay != null)
                        ..._getEventosParaDia(_selectedDay!).map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medical_services_outlined,
                                  size: 18,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  LineAwesomeIcons.download_solid,
                                  color: Colors.white,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _downloadCustomReport,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  LineAwesomeIcons.file_alt,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportFormScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...tratamientos
                          .map(
                            (tratamiento) => buildTratamientoCard(tratamiento),
                          )
                          .toList(),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget buildTratamientoCard(Map<String, dynamic> tratamiento) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final id = tratamiento['id'];
    final isExpanded = _expandedTratamientos.contains(id);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedTratamientos.remove(id);
                } else {
                  _expandedTratamientos.add(id);
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16.0),
                  bottom: isExpanded
                      ? Radius.zero
                      : const Radius.circular(16.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tratamiento['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? LineAwesomeIcons.angle_down_solid
                        : LineAwesomeIcons.angle_right_solid,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tratamiento['consultations'] != null &&
                      tratamiento['consultations'].isNotEmpty)
                    buildInfoRow(
                      'Fecha de Inicio',
                      _formatFecha(
                        tratamiento['consultations'][0]['consultation']['consultationDate'],
                      ),
                    ),
                  const Divider(),
                  if (tratamiento['consultations'] != null &&
                      tratamiento['consultations'].isNotEmpty)
                    buildInfoRow(
                      'Motivo',
                      tratamiento['consultations'][0]['consultation']['motivo'],
                    ),
                  const Divider(),
                  buildInfoRow('Duración', tratamiento['duration']),
                  const Divider(),
                  buildInfoRow('Frecuencia', _formatFrecuencia(tratamiento)),
                  const Divider(),
                  buildInfoRow('Instrucciones', tratamiento['instructions']),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatFecha(String? fechaISO) {
    if (fechaISO == null) return 'No disponible';
    try {
      final date = DateTime.parse(fechaISO);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  String _formatFrecuencia(Map<String, dynamic> t) {
    final valor = t['frequencyValue'];
    final unidad = t['frequencyUnit'];
    if (valor == null || unidad == null) return 'No especificado';
    final plural = valor > 1 ? 's' : '';
    return '$valor vez$plural $unidad';
  }

  Widget buildInfoRow(String title, String? value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            color: isDarkMode ? Colors.white70 : Colors.black38,
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'No disponible',
            style: TextStyle(
              fontSize: 12.0,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
