import 'package:flutter/material.dart';

import '../services/historyService.dart';

class DownloadHistoryButton extends StatelessWidget {
  const DownloadHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Descargar historial'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () async {
            try {
              await HistoryService.downloadMedicalHistoryReport(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historial descargado correctamente.'),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
        ),
      ),
    );
  }
}
