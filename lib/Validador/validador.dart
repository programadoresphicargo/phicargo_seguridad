import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Conexion/Conexion.dart';

class PinValidatorDialog extends StatelessWidget {
  final Function(String) onPinVerified;

  PinValidatorDialog({required this.onPinVerified});

  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();

    return AlertDialog(
      title: const Text('Ingrese su PIN'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/pin.png'),
            TextField(
              obscureText: true,
              controller: pinController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN de 4 dígitos'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 30),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: const Text(
              'Verificar',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            onPressed: () async {
              if (pinController.text != '') {
                Navigator.of(context).pop();

                final response = await http.post(
                    Uri.parse(
                        '${conexion}gestion_viajes/checklist/pin/validar_pin.php'),
                    body: {'pin': pinController.text});
                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  print(data);
                  if (data['respuesta'] == 'correcto') {
                    onPinVerified(data['id_usuario']);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromARGB(255, 154, 4, 4),
                        content: Text(
                          'PIN Inválido',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    );
                  }
                } else {}
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color.fromARGB(255, 154, 4, 4),
                    content: Text(
                      'Ingresa un PIN válido',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              }
            }),
      ],
    );
  }
}
