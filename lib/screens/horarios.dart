import 'package:asd/components/customAppBar.dart';
import 'package:asd/providers/userProvider.dart';
import 'package:asd/services/reservaService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HorariosPage extends StatelessWidget {
  final String doctorName;
  final List<Map<String, dynamic>> horarios;
  final int insuredId;

  const HorariosPage(
      {super.key,
      required this.doctorName,
      required this.horarios,
      required this.insuredId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(
        title1: ('Horarios de $doctorName'),
        icon: LineAwesomeIcons.angle_left_solid,
        colorBack: Colors.teal,
        titlecolor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: horarios.length,
        itemBuilder: (context, index) {
          final horario = horarios[index];
          final slots = generateSlots(
            horario['startTime'],
            horario['endTime'],
            horario['duracion'],
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicio: ${horario['service']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fecha: ${horario['fecha']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((slot) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirmar reserva'),
                                content: Text(
                                    '¿Deseas reservar la cita a las $slot?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Cierra el diálogo
                                      reservarHorario(context, horario, slot,
                                          int.parse(userProvider.patientId ?? '1'));
                                    },
                                    child: const Text('Reservar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          slot,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void reservarHorario(BuildContext context, Map<String, dynamic> horario,
      String slot, int personaId) async {
    final serviceId = horario['serviceId'];
    final fecha = horario['fecha'];

    if (serviceId == null || fecha == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Faltan datos para realizar la reserva')),
        );
      }
      return;
    }

    try {
      await ProgramingMedicalsServices.reservarCita(
        personaId: personaId,
        serviceId: serviceId,
        horaReserva: slot,
        fecha: fecha,
        aseguradoId: insuredId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva exitosa a las $slot')),
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error al reservar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reservar: $e')),
        );
      }
    }
  }

  List<String> generateSlots(String startTime, String endTime, int duration) {
    DateFormat format = DateFormat("HH:mm");
    DateTime start = format.parse(startTime);
    DateTime end = format.parse(endTime);

    List<String> slots = [];

    while (start.isBefore(end)) {
      slots.add(format.format(start));
      start = start.add(Duration(minutes: duration));
    }

    return slots;
  }
}
