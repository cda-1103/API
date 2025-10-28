import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es Web
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

Future<List<String>>headersFromApi(PlatformFile file) async {

  final url = Uri.parse('http://127.0.0.1:8000/api/v1/products/get-headers/');
  var request = http.MultipartRequest('POST', url);

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