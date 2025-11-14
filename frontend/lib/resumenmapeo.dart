import 'package:flutter/material.dart';

class ResumenMapeo extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const ResumenMapeo({super.key, required this.summaryData});

  @override
  Widget build(BuildContext context) {
    // Lee los datos del backend
    final String mensaje = summaryData['mensaje'] ?? '¡Éxito!';
    final int? creados = summaryData['Registros_Creados'];

    return AlertDialog(
      title: Text("Carga Completada"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 16),
          Text(mensaje, textAlign: TextAlign.center),
          if (creados != null)
            Text("Productos Creados: $creados", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Aceptar"),
        ),
      ],
    );
  }
}