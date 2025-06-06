import 'package:flutter/material.dart';
import '../services/enfermedades_service.dart'; // Asegúrate de importar el servicio de enfermedades

class EnfermedadesPage extends StatelessWidget {
  const EnfermedadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enfermedades de la Piel')),
      body: ListView.builder(
        itemCount: EnfermedadesService.obtenerEnfermedades().length,
        itemBuilder: (context, index) {
          final enfermedad = EnfermedadesService.obtenerEnfermedades()[index];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enfermedad['nombre'] ?? 'Sin nombre',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(enfermedad['descripcion'] ?? 'No disponible'),
                  SizedBox(height: 10),
                  Text(
                    'Recomendaciones:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(enfermedad['recomendaciones'] ?? 'No disponible'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
