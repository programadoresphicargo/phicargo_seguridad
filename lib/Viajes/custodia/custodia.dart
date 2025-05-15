import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Conexion/Conexion.dart';

class Custodia extends StatefulWidget {
  String id_viaje;
  String empresa_custodia;
  String nombre_custodios;
  String datos_vehiculo;
  Custodia(
      {Key? key,
      required this.id_viaje,
      required this.empresa_custodia,
      required this.nombre_custodios,
      required this.datos_vehiculo})
      : super(key: key);

  @override
  State<Custodia> createState() => _CustodiaState();
}

class _CustodiaState extends State<Custodia> {
  @override
  Widget build(BuildContext context) {
    Future<void> validar_custodia() async {
      String ruta = 'viajes/odoo/validar_custodia.php';
      final response;
      response = await http.post(
        Uri.parse(conexion + ruta),
        body: {
          'id_viaje': widget.id_viaje,
        },
      );

      try {
        if (response.statusCode == 200) {
          if (response.body == '1') {
            final snackBar = SnackBar(
              duration: Duration(seconds: 10),
              backgroundColor: Colors.blue[700],
              content: const Text(
                'Custodia validada correctamente.',
                style: TextStyle(fontSize: 25),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            Navigator.pop(context, true);
          } else {
            final snackBar = SnackBar(
              duration: Duration(seconds: 10),
              backgroundColor: Colors.blue[700],
              content: Text(
                response.body,
                style: TextStyle(fontSize: 25),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } else {
          final snackBar = SnackBar(
            duration: Duration(seconds: 10),
            backgroundColor: Colors.red[700],
            content: Text(
              'Error_custodia: ${response.statusCode}: ${response.reasonPhrase}',
              style: TextStyle(fontSize: 25),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        final snackBar = SnackBar(
          duration: Duration(seconds: 10),
          backgroundColor: Colors.red[700],
          content: Text(
            'Error exception custodia: ' + response.body,
            style: TextStyle(fontSize: 25),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de custodia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: [
                Text(
                  'Empresa custodia: ${widget.empresa_custodia}',
                  style: const TextStyle(fontSize: 30),
                ),
                Text('Nombre custodios:${widget.nombre_custodios}',
                    style: const TextStyle(fontSize: 30)),
                Text('Datos vehiculo: ${widget.datos_vehiculo}',
                    style: const TextStyle(fontSize: 30)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[700],
        onPressed: () {
          validar_custodia();
        },
        icon: const Icon(
          Icons.check,
          size: 40,
          color: Colors.white,
        ),
        label: const Text(
          'Validar',
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  }
}
