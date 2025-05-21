import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'package:stack_trace/stack_trace.dart';

class PinValidatorDialog extends StatelessWidget {
  final Function(String) onPinVerified;

  PinValidatorDialog({required this.onPinVerified});

  @override
  Widget build(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    String apiUrl = OdooApi();

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
                try {
                  final response = await http.post(
                    Uri.parse('$apiUrl/users/by_pin/${pinController.text}'),
                  );
                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    if (data is Map && data.containsKey('id_usuario')) {
                      onPinVerified(data['id_usuario'].toString());
                    } else {
                      Navigator.pop(context);
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color.fromARGB(255, 154, 4, 4),
                        content: Text(
                          'Error en el servidor',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    );
                  }
                } catch (e, stackTrace) {
                  // Captura el error y el stack trace
                  final trace = Trace.from(stackTrace);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color.fromARGB(255, 154, 4, 4),
                      content: Text(
                        'Error en: $e\nLínea: ${trace.frames.first.line}',
                        style: const TextStyle(fontSize: 25),
                      ),
                    ),
                  );
                }
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
              }
            }),
      ],
    );
  }
}
