import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/appointment_service.dart'; // Importamos el servicio de citas
import '../providers/userProvider.dart'; // Importamos el UserProvider para obtener los datos del paciente

class HorariosAtencionPage extends StatefulWidget {
  const HorariosAtencionPage({super.key});

  @override
  _HorariosAtencionPageState createState() => _HorariosAtencionPageState();
}

class _HorariosAtencionPageState extends State<HorariosAtencionPage> {
  Map<String, dynamic>? horasAtencion;
  String? selectedDay;
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    // Cargar los horarios de atención cuando la página se inicie
    _cargarHorasAtencion();
  }

  // Cargar las horas de atención por organización
  void _cargarHorasAtencion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // final patientId = userProvider.patientId;
    final organizationId = userProvider.organizationId ?? 'defaultPatientId';
    try {
      final data = await AppointmentService.obtenerHorasAtencionPorOrganizacion(
        organizationId,
      ); // Debes asegurarte de usar el servicio correcto
      setState(() {
        horasAtencion = data;
      });
    } catch (e) {
      print("Error al cargar las horas de atención: $e");
    }
  }

  // Formatear la hora a formato legible
  String _formatTime(String? time) {
    if (time == null) return 'Desconocido';
    final dateTime = DateTime.parse(time);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Función para registrar la cita
  void _registrarCita(String selectedDateTime) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patientId = userProvider.patientId;
    final organizationId = userProvider.organizationId;

    try {
      final response = await AppointmentService.crearCita(
        appointmentDatetime: selectedDateTime,
        patientId: patientId ?? 'defaultPatientId',
        organizationId: organizationId ?? 'defaultOrgId',
      );
      // Si la cita fue registrada correctamente, mostramos un mensaje de éxito
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cita registrada'),
          content: Text('Tu cita ha sido registrada exitosamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Manejo de errores
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo registrar la cita: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar Horario de Atención')),
      body: horasAtencion == null
          ? Center(child: CircularProgressIndicator()) // Mostrar cargando
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Mostrar los días disponibles
                  DropdownButton<String>(
                    hint: Text('Seleccionar día'),
                    value: selectedDay,
                    onChanged: (newValue) {
                      setState(() {
                        selectedDay = newValue;
                        selectedTime = null; // Limpiar la hora seleccionada
                      });
                    },
                    items: horasAtencion?['days'].map<DropdownMenuItem<String>>(
                      (day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        );
                      },
                    ).toList(),
                  ),
                  SizedBox(height: 20),
                  // Mostrar las horas disponibles basadas en el día seleccionado
                  if (selectedDay != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona la hora para el $selectedDay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ..._getAvailableTimes().map((time) {
                          return RadioListTile<String>(
                            title: Text(time),
                            value: time,
                            groupValue: selectedTime,
                            onChanged: (String? value) {
                              setState(() {
                                selectedTime = value;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  SizedBox(height: 20),
                  // Botón para registrar la cita
                  ElevatedButton(
                    onPressed: selectedTime != null && selectedDay != null
                        ? () {
                            final selectedDateTime = _getDateTimeString(
                              selectedDay!,
                              selectedTime!,
                            );
                            _registrarCita(selectedDateTime);
                          }
                        : null,
                    child: Text('Registrar Cita'),
                  ),
                ],
              ),
            ),
    );
  }

  // Función para obtener las horas disponibles según el día seleccionado
  List<String> _getAvailableTimes() {
    if (horasAtencion == null || selectedDay == null) return [];

    // Compara los días seleccionados con los horarios
    final startTime = _formatTime(horasAtencion?['startTime']);
    final endTime = _formatTime(horasAtencion?['endTime']);
    final availableTimes = <String>[];

    if (horasAtencion?['days'].contains(selectedDay)) {
      // Suponiendo que el rango de tiempo es el mismo para cada día seleccionado
      availableTimes.add('$startTime - $endTime');
    }

    return availableTimes;
  }

  // Función para obtener la cadena de fecha y hora para registrar la cita
  String _getDateTimeString(String day, String time) {
    final date = DateTime.parse(horasAtencion?['startTime']);
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$formattedDate $time:00.000Z';
  }
}
