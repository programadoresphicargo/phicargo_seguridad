import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../conexion/conexion.dart';
import 'package:http/http.dart' as http;

Future<bool> comprobar_checklist_flota(
    String id_viaje, String id_flota, String tipo_checklist, context) async {
  bool estado;
  String ruta = 'gestion_viajes/checklist/flota/comprobar_checklist.php';

  final response = await http.post(
    Uri.parse(conexion + ruta),
    body: {
      'id_viaje': id_viaje,
      'id_flota': id_flota,
      'tipo_checklist': tipo_checklist,
    },
  );

  if (response.statusCode == 200) {
    if (response.body == '1') {
      estado = true;
    } else {
      estado = false;
    }
    return estado;
  } else {
    throw Exception('Failed to load data from server');
  }
}
