import 'package:flutter/material.dart';
import 'package:frontend/logica_pantalla_carga.dart';


class InventoryUploadPage extends StatefulWidget {
  const InventoryUploadPage({super.key});

  @override
  State<InventoryUploadPage> createState() => _InventoryUploadPageState();
}

// El State ahora es mucho más simple
class _InventoryUploadPageState extends State<InventoryUploadPage> {
  // --- Creamos una instancia de nuestro ViewModel ---
  final UploadHeadersLogic _viewModel = UploadHeadersLogic();

  // --- Nos suscribimos a los cambios del ViewModel ---
  @override
  void initState() {
    super.initState();
    // 'addListener' llama a _onViewModelUpdate cada vez que el ViewModel notifica cambios
    _viewModel.addListener(_onViewModelUpdate); 
  }

  // --- Nos desuscribimos para evitar fugas de memoria ---
  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate); // Quita el oyente
    _viewModel.dispose(); // Libera recursos del ChangeNotifier
    super.dispose();
  }

  // --- Función que fuerza a la UI a redibujarse cuando el ViewModel cambia ---
  void _onViewModelUpdate() {
    setState(() {}); // Llama a setState vacío para reconstruir el build
  }





  // --- Construcción de la Interfaz Gráfica (Usa datos del ViewModel) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Lee el estado 'fileHeaders' del ViewModel
        title: Text(_viewModel.fileHeaders.isEmpty 
            ? 'Carga de Archivo - Paso 1: Seleccionar Archivo' 
            : 'Carga de Archivo - Paso 2: Mapear'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Seleccionar Archivo y Leer Cabeceras'),
                // Llama al método del ViewModel
                // Lee el estado 'isLoading' del ViewModel para habilitar/deshabilitar
                onPressed: _viewModel.isLoading ? null : _viewModel.selectFileAndGetHeaders, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              const SizedBox(height: 20.0),

              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 169, 169, 169),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  // Lee el estado 'statusMessage' del ViewModel
                  _viewModel.statusMessage, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              const SizedBox(height: 40.0),

              ElevatedButton(
                // Habilita/deshabilita leyendo 'fileHeaders' e 'isLoading' del ViewModel
                onPressed: (_viewModel.fileHeaders.isEmpty || _viewModel.isLoading) 
                    ? null 
                    : _viewModel.goToMappingStep, // Llama al método del ViewModel
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('SIGUIENTE: Mapear Columnas'),
              ),
              const SizedBox(height: 12.0),

              // Muestra el indicador leyendo 'isLoading' del ViewModel
              if (_viewModel.isLoading) const Center(child: CircularProgressIndicator()), 
            ],
          ),
        ),
      ),
    );
  }
}
