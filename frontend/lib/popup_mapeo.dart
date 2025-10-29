import 'package:frontend/imports.dart';
import 'package:frontend/logica_pantalla_carga.dart';

void popUpMapeo (BuildContext context, UploadHeadersLogic viewModel) {

  //columnas del archivo
  final List<String> fileHeaders = viewModel.fileHeaders 
      .where((h) => !h.startsWith('unnamed:'))
      .toList();

  //columnas de la base de datos
  final List<String> dbColumns = [
    'serial_number',
    'description',
    'category',
    'brand',
    'type',
    'quantity',
    'location',

  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text('Mapea tus columnas'),
          content: Container(
            width: double.maxFinite, 
            child: SingleChildScrollView(
              child: Column( 
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TÍTULOS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Columnas de excel",
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          "Destino",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Divider(), // Una línea para separar


                  ...fileHeaders.map((fileHeader) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(fileHeader)), 
                          Icon(Icons.arrow_forward),
                          DropdownButton<String>( 
                            hint: Text("Selecciona"),
                            
                            value: null, 
                            
                            items: dbColumns.map((String dbCol) {
                              return DropdownMenuItem<String>(
                                value: dbCol,
                                child: Text(dbCol),
                              );
                            }).toList(),

                            // CORRECCIÓN 4: Faltaba 'onChanged' (obligatorio)
                            onChanged: (String? newValue) {
                              // 
                              // --- AQUÍ VA LA LÓGICA DE MAPEO ---
                              // por medio del mapa en dart 
                              //
                            },
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(); // Esto cierra el popup
              },
            ),
            ElevatedButton(
              child: Text("Confirmar"),
              onPressed: () {
                //
                // --- AQUÍ VA LA LÓGICA DE VALIDACIÓN --- y de envio de el mapeo al api
      
                Navigator.of(context).pop(); 
              },
            ),
          ],
        ), 
      );
    }
  ); 
}