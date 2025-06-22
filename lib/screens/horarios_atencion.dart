import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/appointment_service.dart';
import '../providers/userProvider.dart';
import '../components/customAppBar.dart';

class HorariosAtencionPage extends StatefulWidget {
  const HorariosAtencionPage({super.key});

  @override
  State<HorariosAtencionPage> createState() => _HorariosAtencionPageState();
}

class _HorariosAtencionPageState extends State<HorariosAtencionPage> {
  List<Map<String, dynamic>> horasAtencion = [];
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    _cargarHorasAtencion();
  }

  void _cargarHorasAtencion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final organizationId = userProvider.organizationId ?? 'defaultOrgId';
    try {
      final data = await AppointmentService.obtenerHorasAtencionPorOrganizacion(
        organizationId,
      );
      setState(() {
        horasAtencion = data;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudieron cargar los horarios: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getHorariosDelDia(DateTime day) {
    return horasAtencion.where((h) {
      final start = DateTime.parse(h['startTime']);
      final end = DateTime.parse(h['endTime']);
      final days = List<String>.from(h['days']);
      final weekdayStr = _dayToString(day.weekday);

      final dayDate = DateTime(day.year, day.month, day.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);

      final inRange =
          (dayDate.isAtSameMomentAs(startDate) || dayDate.isAfter(startDate)) &&
          (dayDate.isAtSameMomentAs(endDate) || dayDate.isBefore(endDate));

      return inRange && days.contains(weekdayStr);
    }).toList();
  }

  String _dayToString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'lunes';
      case DateTime.tuesday:
        return 'martes';
      case DateTime.wednesday:
        return 'miercoles';
      case DateTime.thursday:
        return 'jueves';
      case DateTime.friday:
        return 'viernes';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return '';
    }
  }

  String _formatTime(String? time) {
    if (time == null) return 'Desconocido';
    final dateTime = DateTime.parse(time);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      appBar: const CustomAppBar(title1: 'Horarios de Atención'),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarStyle: const CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red),
              defaultTextStyle: TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekendStyle: TextStyle(color: Colors.red),
              weekdayStyle: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: (selectedDay != null)
                  ? _buildHorariosList(_getHorariosDelDia(selectedDay!))
                  : const Center(
                      child: Text(
                        'Seleccione un día para ver los horarios',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorariosList(List<Map<String, dynamic>> horarios) {
    if (horarios.isEmpty) {
      return const Center(
        child: Text(
          'No hay horarios disponibles para este día',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horarios disponibles:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...horarios.map((horario) {
              final startTime = _formatTime(horario['startTime']);
              final endTime = _formatTime(horario['endTime']);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '$startTime - $endTime',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 10, 10, 10),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final start = DateTime.parse(horario['startTime']);
                    final end = DateTime.parse(horario['endTime']);

                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: start.hour,
                        minute: start.minute,
                      ),
                    );

                    if (picked != null) {
                      final selectedDate = selectedDay!;
                      final selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        picked.hour,
                        picked.minute,
                      );

                      final isInRange =
                          selectedDateTime.isAfter(
                            start.subtract(const Duration(seconds: 1)),
                          ) &&
                          selectedDateTime.isBefore(
                            end.add(const Duration(seconds: 1)),
                          );

                      if (isInRange) {
                        final dateStr =
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                        final startTimeIso = selectedDateTime.toIso8601String();
                        final endDateTime = selectedDateTime.add(
                          const Duration(minutes: 30),
                        );
                        final endTimeIso = endDateTime.toIso8601String();

                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final patientId =
                            userProvider.patientId ?? 'defaultPatientId';
                        final organizationId =
                            userProvider.organizationId ?? 'defaultOrgId';

                        try {
                          await AppointmentService.crearCita(
                            date: dateStr,
                            startTime: startTimeIso,
                            endTime: endTimeIso,
                            patientId: patientId,
                            organizationId: organizationId,
                          );

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Cita registrada'),
                              content: const Text(
                                'Tu cita ha sido registrada exitosamente.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Error'),
                              content: Text('No se pudo registrar la cita: $e'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Hora no válida'),
                            content: const Text(
                              'La hora seleccionada no está dentro del horario disponible.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Registrar Cita'),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
