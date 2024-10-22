import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../conexion/conexion.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> comprobar_custodia(String id_viaje) async {
  try {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/odoo/comprobar_custodia.php'),
      body: {'id_viaje': id_viaje},
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);

      if (decodedResponse is List<dynamic>) {
        return List<Map<String, dynamic>>.from(decodedResponse);
      } else {
        // Si el formato no es el esperado
        return [
          {
            'estado': false,
            'mensaje': 'Formato de respuesta no esperado',
            'codigo': 500,
          }
        ];
      }
    } else {
      return [
        {
          'estado': false,
          'mensaje': 'Error en la solicitud',
          'codigo': response.statusCode,
        }
      ];
    }
  } catch (error) {
    return [
      {
        'estado': false,
        'mensaje': 'Error al comprobar custodia',
        'codigo': 500,
        'error': error.toString(),
      }
    ];
  }
}
