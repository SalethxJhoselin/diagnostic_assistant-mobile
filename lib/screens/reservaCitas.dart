import 'package:asd/components/customAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/userProvider.dart';
import '../services/reservaService.dart';

class ReservarCitasPage extends StatefulWidget {
  const ReservarCitasPage({super.key});

  @override
  ReservarCitasPageState createState() => ReservarCitasPageState();
}

class ReservarCitasPageState extends State<ReservarCitasPage> {
  late Future<List<Map<String, dynamic>>> programing;
  late List<Map<String, dynamic>> insureds;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    programing = Future.value([]);
    insureds = [];
    _fetchPrograming();
  }

  Future<void> _fetchPrograming() async {
    try {
      final programingsFuture = ProgramingMedicalsServices.getProgramings();
      final insuredsFuture = await ProgramingMedicalsServices.getInsureds();
      setState(() {
        programing = programingsFuture;
        insureds = insuredsFuture;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching programing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.patientId;

    return Scaffold(
      appBar: const CustomAppBar(
        title1: 'Reserva tu Cita',
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: programing,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay programación disponible'));
                } else {
                  List<Map<String, dynamic>> programings = snapshot.data!;
                  return ListView.builder(
                    itemCount: programings.length,
                    itemBuilder: (context, index) {
                      var doctor = programings[index];
                      var horarios = doctor['horarios'];

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        /*
                        child: CardDoctor(
                          doctorName:
                              doctor['doctorNombre'] ?? 'Nombre no disponible',
                          specialty: doctor['specialty'] ??
                              'Especialidad no disponible',
                          icon: LineAwesomeIcons.user_md_solid,
                          availableSlots:
                              horarios != null && horarios.isNotEmpty
                                  ? "Disponible: ${horarios.length} fechas"
                                  : "No hay fechas disponibles",
                          onReserve: () {
                            // Busca en la lista de asegurados el asegurado con el id_usuario del usuario actual
                            final insured = insureds.firstWhere(
                              (insured) => insured['id_usuario'] == userId,
                              orElse: () => {},
                            );

                            if (insured == {}) {
                              // Si no está asegurado, muestra un mensaje
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No estás asegurado para reservar citas.'),
                                ),
                              );
                              return;
                            }

                            final insuredId = insured['id']; // ID del asegurado

                            if (horarios.isNotEmpty) {
                              // Navega a HorariosPage con el ID del asegurado
                              Navigator.of(context)
                                  .push(
                                FadeThroughPageRoute(
                                  page: HorariosPage(
                                    doctorName: doctor['doctorNombre'],
                                    horarios: horarios,
                                    insuredId:
                                        insuredId, // Pasar el ID del asegurado
                                  ),
                                ),
                              )
                                  .then((selectedSlot) {
                                if (selectedSlot != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Reservaste la cita a las $selectedSlot')),
                                  );
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('No hay horarios disponibles')),
                              );
                            }
                          },
                        ),*/
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
