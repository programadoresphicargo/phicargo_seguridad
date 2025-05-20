import 'package:flutter/material.dart';
import 'package:phicargo_seguridad/Api/api.dart';
import 'package:http/http.dart' as http;

Future<bool> comprobarChecklistContenedor(String idViaje, String idCp,
    String tipoChecklist, BuildContext context) async {
  bool estado = false;
  String apiUrl = OdooApi();

  final uri = Uri.parse(
    '$apiUrl/tms_travel/checklist/comprobar_contenedores/?id_viaje=$idViaje&id_cp=$idCp&tipo_checklist=$tipoChecklist',
  );
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    if (response.body == 'true') {
      estado = true;
    } else {
      estado = false;
    }
    return estado;
  } else {
    throw Exception('Failed to load data from server');
  }
}
