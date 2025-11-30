//archvio de comunicacion con la API
//classe de comunicacion de la api
//incluye los metodos de obtener el inventario desde la base de datos, obtener cabeceras del archivo y enviar el mapeo del archivo

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es Web
import 'package:frontend/product.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ApiService {
  final String _baseUrl = "http://192.168.0.117:8000/api/v1/products/";

  //metodo para obtener el inventario desde la base de datos.
  Future<List<Product>> getInventory({
    bool filterByStock = false,
    String? ordering,
  }) async {
    String endpoint = "inventario/";

    final Map<String, String> queryParameters = {};

    if (filterByStock) {
      queryParameters['quantity__gt'] = '0';
    }
    if (ordering != null) {
      queryParameters['ordering'] = ordering;
    }

    final url = Uri.parse(_baseUrl + endpoint).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<Product> products = productFromJson(
          utf8.decode(response.bodyBytes),
        );
        return products;
      } else {
        throw Exception('Error al cargar invenatario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexion: $e');
    }
  }

  //metodo para obtener las cabeceras del archivo
  Future<List<String>> headersFromApi(PlatformFile file) async {
    String endpoint = 'get-headers/';
    final url = Uri.parse(_baseUrl + endpoint);
    var request = http.MultipartRequest('POST', url);

    //para adjuntar el archivo correctamente tanto en web como en mobile/desktop se usa KIsWeb
    if (kIsWeb) {
      // Para Web
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
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
        throw Exception(
          'Error al obtener las cabeceras: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }

  //metodo para enviar el mapeo del archivo completo a la API
  Future<void> sendMapping(PlatformFile file, String jsonString) async {
    String endpoint = "process-file/";
    final url = Uri.parse(_baseUrl + endpoint);
    var request = http.MultipartRequest('POST', url);
    request.fields['mapping'] = jsonString;
    //para adjuntar el archivo correctamente tanto en web como en mobile/desktop
    if (kIsWeb) {
      // Para Web
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
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
}
