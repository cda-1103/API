//archivo que contiene la logica del mapeo del archivo


import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/imports.dart';
import 'package:frontend/comunication_api.dart';

class PopupLogic extends ChangeNotifier{

  Map<String, String?> _mappingState = {};
  Map<String, String?> get mappingState => _mappingState;

final List<String> dbColumns = [
  'serial_number',
  'description',
  'quantity'
];


//estados con los que se va a trabajar
bool _isSubmitting = false;
bool get isSubmitting => _isSubmitting;

//falta agregar estadp de completado para mostrar al usuario
String? _validationError;
String?  get validationError => _validationError;


void initializeMapping(List<String>fileHeaders){
  Map<String, String?> mapaTemporal = {};

  for (String excelHeader in fileHeaders){

    if(dbColumns.contains(excelHeader.toLowerCase())){
      mapaTemporal[excelHeader] = excelHeader.toLowerCase();
    }else {
      mapaTemporal[excelHeader] = null;
    }
  }
  _mappingState = mapaTemporal;
}

//esto es para actualizar el mapa del mapeo 
void updateMapping(String fileHeader, String? selectedDbcolumn){
  _mappingState[fileHeader] = selectedDbcolumn ; 

  notifyListeners();
}

//metodo para validar que los campos obligatorios esten incluidos, se validan que no hayan duplicados, para retornar true, es decir todo esta bien
bool _validateMapping(){
  final List<String> columnasObligatorias = [
    'serial_number',
    'description',
    'quantity'
  ];

  if (_validationError != null){
  _validationError = null;
  notifyListeners();
  }

  //aqui se validan si los campos obligatoritos estan incluidos
  for (int i = 0; i < columnasObligatorias.length; i++ ){
      if(_mappingState.containsValue(columnasObligatorias[i])){
        continue;
      }else{
        //se muestra al usuario que columna de las obligatorias falta mapear
        _validationError = 'Error: falta mapear la columna: ${columnasObligatorias[i]}';
        notifyListeners();
        return false;
      }
  }
  //se obtiene la lista con los valores activos del mapeo
  final List<String?> listaValoresAct = _mappingState.values.where((valor) => valor != null).toList();

  //se hace un toSet que no acepta repetidos
  final Set<String?> valoresUnicos = listaValoresAct.toSet();

  //aqui se verifica por medio de una comparacion si hay duplicados o no
  if(listaValoresAct.length != valoresUnicos.length){
    _validationError = 'Hay duplicados en el mapeo';
    notifyListeners();
    return false;
  }

    return true;
    
  }

  Future<void>sendMap(PlatformFile file) async {
    if(!_validateMapping()){
      return; 
    }
    _isSubmitting = true;
    notifyListeners();

    final Map <String,String> mapaLimpio = {};

    _mappingState.forEach((key, value) {
      if(value != null){
        mapaLimpio[key] = value ;
      }
    },);

    try{
      String jsonString = jsonEncode(mapaLimpio);

      await sendMapping(file, jsonString);

    }catch(e){
      _validationError = e.toString();
      notifyListeners();

    }

    finally {
      _isSubmitting = false;
      notifyListeners();
      }  
  }


}