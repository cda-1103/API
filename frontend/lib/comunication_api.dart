//archvio de comunicacion con la API
//contiene tanto la funcion de extraer las cabeceras del archivo, como la funcion que mapea el archivo


import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es Web
import 'package:flutter/material.dart';
import 'package:frontend/product.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:frontend/product.dart';


//funcion para obtener las cabeceras del archivo
Future<List<String>>headersFromApi(PlatformFile file) async {

  final url = Uri.parse('http://127.0.0.1:8000/api/v1/products/get-headers/');
  var request = http.MultipartRequest('POST', url);

  //para adjuntar el archivo correctamente tanto en web como en mobile/desktop se usa KIsWeb
  if (kIsWeb) {
    // Para Web
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,

      )
    );
  } else {
    // Para Mobile/Desktop
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      ),
    );
  }
  try {
    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<String> headers = List<String>.from(responseData['headers']);
      return headers;
    } else {
      throw Exception('Error al obtener las cabeceras: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al conectar con la API: $e');
  }
}

//funcion para enviar el mapeo del archivo completo a la API
Future <void> sendMapping(PlatformFile file, String jsonString) async {

  final url = Uri.parse('http://127.0.0.1:8000/api/v1/products/process-file/'); 
  var request = http.MultipartRequest('POST', url);
  request.fields['mapping'] = jsonString;
  //para adjuntar el archivo correctamente tanto en web como en mobile/desktop
  if (kIsWeb) {
    // Para Web
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,

      )
    );
  } else {
    // Para Mobile/Desktop
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: file.name,
      ),
    );
  }
  try {
    final streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return;
    } else {
      throw Exception('Error al enviar el mapeo: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al conectar con la API: $e');
  }
}


class ApiService{
  final String _baseUrl = "http://127.0.0.1:8000/api/v1/products/";

  Future<List<Product>> getInventory({bool filterByStock = false}) async {
    String endpoint = "inventario/";

    if (filterByStock){
      endpoint += "?quantity__gt=0";
    }

    final url = Uri.parse(_baseUrl + endpoint);

    try{
      final response = await http.get(url);

      if (response.statusCode == 200){
        final List<Product> products = productFromJson(utf8.decode(response.bodyBytes));
        return products;
      } else {
        throw Exception('Error al cargar invenatario: ${response.statusCode}');
      }
    }catch (e) {
      throw Exception('Error de conexion: $e');
    }

  }
}