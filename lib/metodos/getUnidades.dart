import 'dart:convert';

import 'package:http/http.dart' as http;

import '../conexion/conexion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UnidadesFetcher {
  static Future<List<String>> fetchUnidades() async {
    final response = await http.get(Uri.parse(
        conexion + 'gestion_viajes/checklist/buscador/getUnidades.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) => item['unidad'].toString()).toList();
      } else {
        throw Exception('Los datos de la API no son una lista.');
      }
    } else {
      throw Exception('Fallo al cargar los datos desde la API');
    }
  }
}

class operadoresFetcher {
  static Future<List<String>> fetchOperadores() async {
    final response = await http.get(Uri.parse(
        '${conexion}gestion_viajes/checklist/buscador/getOperadores.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) => item.toString()).toList();
      } else {
        throw Exception('Los datos de la API no son una lista.');
      }
    } else {
      throw Exception('Fallo al cargar los datos desde la API');
    }
  }
}

class FlotaFetcher {
  static Future<List<String>> fetchFlota() async {
    final response = await http.post(
      Uri.parse(conexion + 'maniobras/data/get_flota.php'),
      body: {
        'fleet_type': 'tractor',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) => item['name'].toString()).toList();
      } else {
        throw Exception('Los datos de la API no son una lista.');
      }
    } else {
      throw Exception('Fallo al cargar los datos desde la API');
    }
  }
}
