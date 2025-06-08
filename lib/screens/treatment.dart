import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/reportFormScreen.dart';
import '../services/tramientoService.dart';

class TratamientosPage extends StatefulWidget {
  const TratamientosPage({super.key});

  @override
  TratamientosPageState createState() => TratamientosPageState();
}

class TratamientosPageState extends State<TratamientosPage> {
  late Future<Map<String, dynamic>> _futureTratamientos;
  late Future<List<Map<String, dynamic>>> _futureTratamientosDetalle;
  final Set<String> _expandedTratamientos = {};
  CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<DateTime, List<String>> eventosTratamiento = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;

  List<Map<String, dynamic>> _getTratamientosConHorasParaDia(
    Map<String, dynamic> data,
    DateTime diaSeleccionado,
  ) {
    final diaUTC = DateTime.utc(
      diaSeleccionado.year,
      diaSeleccionado.month,
      diaSeleccionado.day,
    );

    final tratamientos = <Map<String, dynamic>>[];

    data.forEach((_, value) {
      final descripcion = value['description'];
      final fechas = (value['dates'] as List<dynamic>)
          .map((d) => DateTime.parse(d))
          .toList();

      final horasEnEseDia = fechas
          .where(
            (fecha) =>
                fecha.year == diaUTC.year &&
                fecha.month == diaUTC.month &&
                fecha.day == diaUTC.day,
          )
          .map((f) => f.toLocal())
          .toList();

      if (horasEnEseDia.isNotEmpty) {
        tratamientos.add({'description': descripcion, 'horas': horasEnEseDia});
      }
    });

    return tratamientos;
  }

  @override
  void initState() {
    super.initState();
    _futureTratamientos = TratamientoService.getRecordatoriosPorPaciente(
      context,
    );
    _futureTratamientosDetalle = TratamientoService.getTratamientosFromContext(
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (e.toString().contains('noAppToOpenFile')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reporte guardado en Descargas, pero no se pudo abrir. Por favor instale un visor de PDF.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (e.toString().contains('canceló la selección')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La generación del reporte fue cancelada.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar el reporte: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _getEventosParaDia(DateTime dia) {
    return eventosTratamiento[DateTime.utc(dia.year, dia.month, dia.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(
        title: const Text('Mis Tratamientos'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primaryContainer, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(LineAwesomeIcons.angle_left_solid),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _futureTratamientos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 48,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron tratamientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final recordatorios = snapshot.data!;
              eventosTratamiento.clear();

              recordatorios.forEach((_, value) {
                final descripcion = value['description'] ?? '';
                final fechas = (value['dates'] as List<dynamic>)
                    .map((d) => DateTime.parse(d))
                    .toList();

                for (final fecha in fechas) {
                  final dia = DateTime.utc(fecha.year, fecha.month, fecha.day);
                  eventosTratamiento
                      .putIfAbsent(dia, () => [])
                      .add(descripcion);
                }
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(18),
                        elevation: 1,
                        color: colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TableCalendar<String>(
                            firstDay: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDay: DateTime.now().add(
                              const Duration(days: 365),
                            ),
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
                              defaultTextStyle:
                                  theme.textTheme.bodyMedium ??
                                  const TextStyle(),
                              weekendTextStyle:
                                  theme.textTheme.bodyMedium ??
                                  const TextStyle(),
                              outsideTextStyle:
                                  (theme.textTheme.bodyMedium ??
                                          const TextStyle())
                                      .copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.3),
                                      ),
                            ),
                            eventLoader: _getEventosParaDia,
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle:
                                  (theme.textTheme.titleMedium ??
                                          const TextStyle())
                                      .copyWith(fontWeight: FontWeight.w600),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: colorScheme.onSurface,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedDay != null)
                      ..._getTratamientosConHorasParaDia(
                        recordatorios,
                        _selectedDay!,
                      ).map(
                        (tratamiento) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _ConsultaTimelineItem(
                            consulta: {
                              'description': tratamiento['description'],
                              'horas': tratamiento['horas'],
                            },
                            isFirst: false,
                            isLast: false,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ActionButton(
                            icon: LineAwesomeIcons.download_solid,
                            onPressed: _isLoading
                                ? null
                                : _downloadCustomReport,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: LineAwesomeIcons.file_alt,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportFormScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Todos los tratamientos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _futureTratamientosDetalle,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.teal,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error al cargar los tratamientos: ${snapshot.error}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.medical_services_outlined,
                                    size: 48,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron tratamientos',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final tratamientos = snapshot.data!;
                          return Column(
                            children: tratamientos
                                .map(
                                  (t) => _TratamientoCard(
                                    tratamiento: t,
                                    isExpanded: _expandedTratamientos.contains(
                                      t['id'],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        final id = t['id'];
                                        if (_expandedTratamientos.contains(
                                          id,
                                        )) {
                                          _expandedTratamientos.remove(id);
                                        } else {
                                          _expandedTratamientos.add(id);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsultaTimelineItem extends StatelessWidget {
  final Map<String, dynamic> consulta;
  final bool isFirst;
  final bool isLast;

  const _ConsultaTimelineItem({
    required this.consulta,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 12,
                color: colorScheme.outline.withOpacity(0.2),
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 3),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 12,
                color: colorScheme.outline.withOpacity(0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(18),
            elevation: 1,
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.medical_services, color: Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consulta['description'],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List<Widget>.from(
                    (consulta['horas'] as List<DateTime>).map(
                      (hora) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ActionButton({
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.teal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: onPressed,
            ),
    );
  }
}

class _TratamientoCard extends StatelessWidget {
  final Map<String, dynamic> tratamiento;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TratamientoCard({
    required this.tratamiento,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tratamiento['description'] ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  if (tratamiento['consultations'] != null &&
                      tratamiento['consultations'].isNotEmpty)
                    _InfoRow(
                      label: 'Fecha de Inicio',
                      value: _formatFecha(
                        tratamiento['consultations'][0]['consultation']['consultationDate'],
                      ),
                    ),
                  const _Divider(),
                  if (tratamiento['consultations'] != null &&
                      tratamiento['consultations'].isNotEmpty)
                    _InfoRow(
                      label: 'Motivo',
                      value:
                          tratamiento['consultations'][0]['consultation']['motivo'],
                    ),
                  const _Divider(),
                  _InfoRow(label: 'Duración', value: tratamiento['duration']),
                  const _Divider(),
                  _InfoRow(
                    label: 'Frecuencia',
                    value: _formatFrecuencia(tratamiento),
                  ),
                  const _Divider(),
                  _InfoRow(
                    label: 'Instrucciones',
                    value: tratamiento['instructions'],
                  ),
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
      return DateFormat('dd/MM/yyyy').format(date);
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No disponible',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
    );
  }
}
