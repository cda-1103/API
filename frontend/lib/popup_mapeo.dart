//Interfaz de la ventana PopUp de mapeo

import 'package:file_picker/file_picker.dart';
import 'package:frontend/imports.dart';
import 'package:frontend/logic_map_file.dart'; 


class PopupMapFile extends StatefulWidget {
  final List<String> fileHeaders;
  final PlatformFile file; 

  const PopupMapFile({
    super.key,
    required this.fileHeaders,
    required this.file,
  });

  @override
  State<PopupMapFile> createState() => _PopupMapFileState();
}

class _PopupMapFileState extends State<PopupMapFile> {
  final PopupLogic _viewModel = PopupLogic(); 

  @override
  void initState() {
    super.initState();
    

    _viewModel.addListener(() {
      setState(() {});
    });


    _viewModel.initializeMapping(widget.fileHeaders);
  }

  @override
  void dispose() {
    _viewModel.dispose(); 
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_viewModel.isSubmitting, 
      
      child: AlertDialog(
        title: Text('Mapea tus columnas'),
        
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView( 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Columnas del excel", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Columnas destino", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Divider(),
                ...widget.fileHeaders.map((fileheader) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(label: Text(fileheader)),
                        Icon(Icons.arrow_forward_ios, size: 16), 

                        DropdownButton<String>(
                          hint: Text('Selecciona'),
                          // Conexión LEER: Lee el valor del cerebro
                          value: _viewModel.mappingState[fileheader],
                          
                          // Lee las opciones del archivo logic_map_file de las columnas disponibles en la base de datos
                          items: _viewModel.dbColumns.map((String dbCol) {
                            return DropdownMenuItem<String>(
                              value: dbCol,
                              child: Text(dbCol),
                            );
                          }).toList() 
                            ..insert(0, DropdownMenuItem(
                              value: null,
                              child: Text("Selecciona"),
                            )),
                          

                          onChanged: (String? newValue) {
                            // actualiza la lista con el nuevo valor
                            _viewModel.updateMapping(fileheader, newValue);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(), 
                //aqui se debe mostrar el mensaje de completado si _viewmodel.vailaditonerror == null
                if (_viewModel.validationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _viewModel.validationError!, 
                      style: TextStyle(color: Colors.red), 
                    ),
                  ),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: _viewModel.isSubmitting ? null : () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: _viewModel.isSubmitting ? null : () {

              _viewModel.sendMap(widget.file); //envia el archivo
            },
            
            child: _viewModel.isSubmitting
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: const Color.fromARGB(255, 21, 186, 240)))
                : Text("Confirmar"),
          ),
        ],
      ), // <-- Aquí cierra el AlertDialog
    ); // <-- Aquí cierra el PopScope
  }
}