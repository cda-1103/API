
import 'package:flutter/foundation.dart'; // Para kIsWeb y ChangeNotifier
import 'package:file_picker/file_picker.dart';
import 'package:frontend/comunication_api.dart'; 

// Hereda de ChangeNotifier para notificar a la UI cuando los datos cambien
class UploadHeadersLogic extends ChangeNotifier {
  
  // --- Estados que la UI necesita saber ---
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  List<String> _fileHeaders = [];
  String _statusMessage = ' Ningún archivo seleccionado';

  // --- Getters públicos para que la UI lea los estados de carga del archivo---
  PlatformFile? get selectedFile => _selectedFile;
  bool get isLoading => _isLoading;
  List<String> get fileHeaders => _fileHeaders;
  String get statusMessage => _statusMessage;

  // --- Lógica de Negocio ---
  Future<void> selectFileAndGetHeaders() async {
    // 1. Limpia estado anterior y notifica a la UI
    _selectedFile = null;
    _fileHeaders = [];
    _isLoading = true;
    _statusMessage = 'Seleccionando archivo...';
    notifyListeners(); // Avisa a la UI que actualice

    try {
      // 2. Abre el selector de archivos de la computadora
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb, 
      );

      if (result != null) {
        final file = result.files.first;
        _selectedFile = file; // Guarda el archivo internamente
        _statusMessage = 'Archivo: ${file.name}. Obteniendo cabeceras...';
        notifyListeners(); // Actualiza UI

        // 3. Llama a la API
        final headers = await headersFromApi(file); 

        // 4. Si tiene éxito, guarda cabeceras y notifica al usuario
        _fileHeaders = headers;
        _isLoading = false;
        _statusMessage = 'Cabeceras recibidas (${headers.length}). Listo para mapear.';
        notifyListeners(); // Actualiza UI

      } else {
        // Usuario canceló
        _statusMessage = 'Selección cancelada.';
        _isLoading = false;
        notifyListeners(); // Actualiza UI
      }
    } catch (e) {
      // 5. Si ocurre un error
      _isLoading = false;
      _statusMessage = 'Error: $e';
      _selectedFile = null; 
      _fileHeaders = []; 
      notifyListeners(); // Actualiza UI con el error
    }
  }

}