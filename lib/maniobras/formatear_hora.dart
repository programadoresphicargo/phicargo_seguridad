import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatoFechaInvalidoException implements Exception {
  final String mensaje;

  FormatoFechaInvalidoException(this.mensaje);

  @override
  String toString() {
    return 'FormatoFechaInvalidoException: $mensaje';
  }
}

Widget formatearFechaYHora(String fechaYHora) {
  try {
    DateTime fechaObjeto = DateTime.parse(fechaYHora);
    String fecha12h = DateFormat("dd-MM-yyyy hh:mm a").format(fechaObjeto);
    List<String> partes = fecha12h.split(' ');
    if (partes.length != 3) {
      throw FormatoFechaInvalidoException(
          'El formato de fecha y hora no es válido');
    }
    String fecha = partes[0];
    String hora = partes[1] + ' ' + partes[2];

    return Row(
      children: [
        Text(
          '$fecha ',
          style: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          hora,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  } catch (e) {
    return const Text(
      'Error al formatear fecha y hora.',
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }
}
