import 'package:asd/components/customAppBar.dart';
import 'package:flutter/material.dart';
import '../services/enfermedades_service.dart';

class EnfermedadesPage extends StatefulWidget {
  const EnfermedadesPage({super.key});

  @override
  _EnfermedadesPageState createState() => _EnfermedadesPageState();
}

class _EnfermedadesPageState extends State<EnfermedadesPage> {
  List<Map<String, String>> enfermedades =
      EnfermedadesService.obtenerEnfermedades();
  List<Map<String, String>> enfermedadesFiltradas = [];
  String currentQuery = '';

  @override
  void initState() {
    super.initState();
    enfermedadesFiltradas = List.from(enfermedades);
  }

  void _buscarEnfermedades(String query) {
    final resultados = enfermedades.where((enfermedad) {
      final nombre = enfermedad['nombre']?.toLowerCase() ?? '';
      return nombre.contains(query.toLowerCase());
    }).toList();

    setState(() {
      enfermedadesFiltradas = resultados;
      currentQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      appBar: const CustomAppBar(title1: 'Enfermedades de la Piel'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 16),
              if (enfermedadesFiltradas.isEmpty)
                const Center(
                  child: Text(
                    'No se encontraron enfermedades',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: enfermedadesFiltradas.length,
                  itemBuilder: (context, index) {
                    return buildEnfermedadCard(enfermedadesFiltradas[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _buscarEnfermedades,
      decoration: InputDecoration(
        hintText: 'Buscar enfermedad...',
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: currentQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black54),
                onPressed: () {
                  _buscarEnfermedades('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildEnfermedadCard(Map<String, String> enfermedad) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF3E4A59),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHighlightedText(
                    enfermedad['nombre'] ?? 'Sin nombre',
                    currentQuery,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow('Descripción', enfermedad['descripcion']),
                const Divider(color: Colors.black12),
                buildInfoRow('Recomendaciones', enfermedad['recomendaciones']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            color: Colors.black45,
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'No disponible',
            style: const TextStyle(fontSize: 14.0, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final startIndex = textLower.indexOf(queryLower);

    if (startIndex == -1) {
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: const TextStyle(color: Color.fromARGB(255, 218, 213, 171)),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
