import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../conexion/conexion.dart';
import 'package:http/http.dart' as http;

Future<bool> comprobar_checklist_contenedor(String id_viaje, String id_cp,
    String estado_checklist, BuildContext context) async {
  bool estado = false;

  try {
    String ruta =
        'gestion_viajes/checklist/contenedor/comprobar_checklist_contenedor.php';

    final response = await http.post(
      Uri.parse(conexion + ruta),
      body: {
        'id_viaje': id_viaje,
        'id_cp': id_cp,
        'tipo_checklist': estado_checklist
      },
    );

    if (response.statusCode == 200) {
      if (response.body == '1') {
        estado = true;
      } else {
        estado = false;
      }
    } else {
      throw Exception('Failed to load data from server');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error al comprobar el checklist: $e',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  return estado;
}
