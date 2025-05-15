import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/conexion/conexion.dart';

class ViajesService {
  final BuildContext context;

  ViajesService(this.context);

  Future<bool> fetchViajes(String idViaje) async {
    try {
      final url = Uri.parse(
          '${conexion}viajes/disponibilidad/comprobar_disponibilidad.php');
      final response = await http.post(url, body: {'id_viaje': idViaje});

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          return true; // No hay viajes, se considera disponible.
        } else {
          _showViajesDialog(jsonResponse);
          return false; // Hay viajes, no está disponible.
        }
      } else {
        print('Error: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        return false; // Error de servidor, asumimos no disponible.
      }
    } catch (e) {
      print('Error al obtener los datos: $e');
      return false; // Error de red o excepción, asumimos no disponible.
    }
  }

  // Función para manejar una respuesta vacía
  void _handleEmptyResponse() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sin resultados'),
          content:
              Text('No se encontraron datos para el ID de viaje especificado.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar los datos en un AlertDialog
  void _showViajesDialog(List<dynamic> viajes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 154, 4, 4),
          title: const Text(
            'Equipo en uso',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'El equipo asignado para este viaje está actualmente en uso. Para activar una nueva maniobra o viaje, primero debes finalizar la maniobra o viaje anterior:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
              Column(
                children: viajes.map((viaje) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Equipo: ${viaje['equipo'] ?? 'Sin equipo'} '
                      'en ${viaje['estado'] ?? 'Sin estado'} '
                      'con referencia: ${viaje['referencia'] ?? 'Sin referencia'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  'Recuerda finalizar viajes y maniobras al reingresar las unidades al patio para evitar este tipo de errores.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ],
        );
      },
    );
  }
}
