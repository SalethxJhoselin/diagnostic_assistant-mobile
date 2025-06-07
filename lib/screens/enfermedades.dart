import 'package:flutter/material.dart';
import '../services/enfermedades_service.dart'; // Asegúrate de importar el servicio de enfermedades

class EnfermedadesPage extends StatefulWidget {
  const EnfermedadesPage({super.key});

  @override
  _EnfermedadesPageState createState() => _EnfermedadesPageState();
}

class _EnfermedadesPageState extends State<EnfermedadesPage> {
  // Lista de enfermedades cargadas desde el servicio
  List<Map<String, String>> enfermedades =
      EnfermedadesService.obtenerEnfermedades();

  // Lista de enfermedades que se mostrarán, que se filtra dinámicamente
  List<Map<String, String>> enfermedadesFiltradas = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos enfermedadesFiltradas con todas las enfermedades al inicio
    enfermedadesFiltradas = List.from(enfermedades);
  }

  // Método de búsqueda que filtra las enfermedades
  void _buscarEnfermedades(String query) {
    final resultados = enfermedades.where((enfermedad) {
      final nombreEnfermedad = enfermedad['nombre']?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return nombreEnfermedad.contains(queryLower); // Compara en minúsculas
    }).toList();

    setState(() {
      enfermedadesFiltradas = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enfermedades de la Piel'),
        backgroundColor: Color(0xFF3E4A59), // Color de fondo para la AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EnfermedadesSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _buscarEnfermedades,
              decoration: InputDecoration(
                labelText: 'Buscar enfermedad...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: enfermedadesFiltradas.length,
              itemBuilder: (context, index) {
                final enfermedad = enfermedadesFiltradas[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enfermedad['nombre'] ?? 'Sin nombre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Descripción:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(enfermedad['descripcion'] ?? 'No disponible'),
                        SizedBox(height: 10),
                        Text(
                          'Recomendaciones:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(enfermedad['recomendaciones'] ?? 'No disponible'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EnfermedadesSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Aquí puedes mostrar los resultados de la búsqueda
    final results = EnfermedadesService.obtenerEnfermedades().where((
      enfermedad,
    ) {
      return enfermedad['nombre']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final enfermedad = results[index];
        return ListTile(
          title: Text(enfermedad['nombre'] ?? 'Sin nombre'),
          subtitle: Text(enfermedad['descripcion'] ?? 'Sin descripción'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Sugerencias mientras el usuario escribe
    final suggestions = EnfermedadesService.obtenerEnfermedades().where((
      enfermedad,
    ) {
      return enfermedad['nombre']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final enfermedad = suggestions[index];
        return ListTile(
          title: Text(enfermedad['nombre'] ?? 'Sin nombre'),
          subtitle: Text(enfermedad['descripcion'] ?? 'Sin descripción'),
        );
      },
    );
  }
}
