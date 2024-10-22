import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void alerta(String titulo, String mensaje, Icon icon, context) {
  Flushbar(
    icon: icon,
    backgroundColor: const Color.fromARGB(255, 154, 4, 4),
    duration: const Duration(seconds: 5),
    message: mensaje,
    messageSize: 13,
    titleText: Text(titulo,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
  ).show(context);
}

void alerta_success(String titulo, String mensaje, Icon icon, context) {
  Flushbar(
    icon: icon,
    backgroundColor: Color.fromARGB(255, 20, 204, 121),
    duration: const Duration(seconds: 8),
    message: mensaje,
    messageSize: 13,
    titleText: Text(titulo,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
  ).show(context);
}
