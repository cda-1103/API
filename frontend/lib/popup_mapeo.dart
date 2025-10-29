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
    'Omitir' // <-- Te recomiendo mucho añadir una opción para ignorar
  ];

  /* NOTA: Tu mapa 'userChoose' está declarado aquí, pero para que 
  funcione y guarde la selección, necesitarás:
  1. Moverlo a tu 'viewModel' (para que el estado persista).
  2. Usar un 'StatefulBuilder' para refrescar el popup.
  3. Usar ese mapa en 'value' y 'onChanged' del DropdownButton.
  
  Lo dejaré como 'value: null' por ahora, como pediste.
  */

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
              child: Column( // <-- El .map debe ir DENTRO de 'children'
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

                  // --- MAPEO DE FILAS ---
                  // CORRECCIÓN 1: El map va DENTRO de 'children' y con sintaxis correcta
                  ...fileHeaders.map((fileHeader) { // Se usa 'fileHeader' (singular)
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(fileHeader)), // Se usa 'fileHeader'
                          Icon(Icons.arrow_forward),
                          DropdownButton<String>( // Es bueno tiparlo
                            hint: Text("Selecciona"),
                            
                            // CORRECCIÓN 2: 'value' debe venir de tu lógica de estado
                            // Lo dejo null por ahora.
                            value: null, 
                            
                            // CORRECCIÓN 3: Faltaba la propiedad 'items'
                            items: dbColumns.map((String dbCol) {
                              return DropdownMenuItem<String>(
                                value: dbCol,
                                child: Text(dbCol),
                              );
                            }).toList(),

                            // CORRECCIÓN 4: Faltaba 'onChanged' (obligatorio)
                            onChanged: (String? newValue) {
                              // 
                              // --- AQUÍ VA TU LÓGICA DE MAPEO ---
                              // (Ej: viewModel.actualizarMapeo(fileHeader, newValue); )
                              //
                            },
                          )
                        ],
                      ),
                    );
                  }).toList(), // <-- CORRECIÓN 5: .toList() es necesario
                ],
              ),
            ),
          ), // <-- El 'Container' se cierra aquí
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
                // --- AQUÍ VA TU LÓGICA DE VALIDACIÓN ---
                // (Ej: if (viewModel.mapeoEsValido()) { ... } )
                //
                Navigator.of(context).pop(); 
              },
            ),
          ],
        ), 
      );
    }
  ); 
}