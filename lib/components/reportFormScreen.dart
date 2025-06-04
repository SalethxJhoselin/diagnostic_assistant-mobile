import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/tramientoService.dart';

class ReportFormScreen extends StatefulWidget {
  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _frequencyUnit;
  int? _minApplications;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart)
          _startDate = picked;
        else
          _endDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print(
        'Generating report from ReportFormScreen with parameters: '
        'Start Date: ${_startDate?.toIso8601String().split('T')[0]}, '
        'End Date: ${_endDate?.toIso8601String().split('T')[0]}, '
        'Frequency Unit: $_frequencyUnit, '
        'Min Applications: $_minApplications',
      );
      await TratamientoService.downloadCustomTreatmentReport(
        context,
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
        frequencyUnit: _frequencyUnit,
        minApplications: _minApplications,
      );
      print('Report generated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reporte guardado en Descargas y abierto exitosamente'),
        ),
      );
    } catch (e) {
      print('Error in ReportFormScreen: $e');
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
          SnackBar(content: Text('Error al generar el reporte: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generar Reporte de Tratamientos')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(
                    'Seleccionar Fecha de Inicio: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'No seleccionada'}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(
                    'Seleccionar Fecha de Fin: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'No seleccionada'}',
                  ),
                ),
                DropdownButton<String>(
                  hint: Text('Unidad de Frecuencia'),
                  value: _frequencyUnit,
                  items: ['daily', 'weekly', 'monthly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _frequencyUnit = newValue;
                    });
                  },
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mínimo de Aplicaciones',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _minApplications = int.tryParse(value);
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateReport,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Generar Reporte'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
