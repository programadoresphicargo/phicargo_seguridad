import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'package:phicargo_seguridad/metodos/convertir_fecha.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../Alertas/alerta.dart';
import 'checklist.dart';

class Record {
  final String id;
  final String id_cp;
  final String x_reference;
  final String x_reference_2;

  Record({
    required this.id,
    required this.id_cp,
    required this.x_reference,
    required this.x_reference_2,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'].toString(),
      id_cp: json['id_cp'].toString(),
      x_reference: json['x_reference'].toString(),
      x_reference_2: json['x_reference_2'].toString(),
    );
  }
}

class detalle_maniobra extends StatefulWidget {
  String id_maniobra;
  Color color_view;

  detalle_maniobra(
      {super.key, required this.id_maniobra, required this.color_view});

  @override
  State<detalle_maniobra> createState() => _detalle_maniobraState();
}

class _detalle_maniobraState extends State<detalle_maniobra> {
  Map<String, bool> mapa = {};
  bool isLoading = false;

  bool todosTrue = false;
  late String inicio_programado = '';
  late String terminal = '';
  late String tipo_maniobra = '';
  late String operador_id = '';
  late String vehicle_id = '';
  late String trailer1_id = '';
  late String trailer2_id = '';
  late String dolly_id = '';
  late String motogenerador_1 = '';
  late String motogenerador_2 = '';
  late String estado_maniobra = '';
  List<Record> misDatos = [];
  @override
  void initState() {
    super.initState();
    getManiobra(widget.id_maniobra);
  }

  Future<bool> comprobarDisponibilidadUnidades() async {
    String apiUrl = OdooApi();
    String mensaje = '';
    try {
      final response = await http.get(Uri.parse(
          '$apiUrl/maniobras/comprobar_disponibilidad_equipo/${widget.id_maniobra}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          for (var item in data) {
            mensaje +=
                ('${item['equipo']} - se encuentra en: ${item['estado']} : ${item['referencia']}\n');
          }

          _showAlertDialog(mensaje);
          return false;
        }

        return true;
      } else {
        alerta(response.body, response.body, Icon(Icons.error), context);
        return false;
      }
    } catch (e) {
      alerta(
          'Error',
          'No se pudo validar la disponibilidad del equipo. Inténtalo de nuevo.',
          const Icon(Icons.error),
          context);
      return false;
    }
  }

  void _showAlertDialog(String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 154, 4, 4),
          title: const Text(
            'Alerta de seguridad: No se puede iniciar una nueva maniobra.',
            style: TextStyle(fontSize: 40, color: Colors.white),
          ),
          content: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'El equipo asignado para esta maniobra está actualmente en uso. Para activar una nueva maniobra o viaje, primero debes finalizar la maniobra o viaje anterior.',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    '${body}',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar',
                  style: TextStyle(fontSize: 40, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> getManiobra(String id_maniobra) async {
    String apiUrl = OdooApi();

    try {
      setState(() {
        isLoading = true;
      });
      final response =
          await http.get(Uri.parse('$apiUrl/maniobras/by_id/$id_maniobra'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          tipo_maniobra = data['tipo_maniobra'] ?? '';
          inicio_programado = data['inicio_programado'] ?? '';
          terminal = data['terminal'] ?? '';
          operador_id = data['nombre_operador'] ?? '';
          vehicle_id = data['vehicle_name'] ?? '';
          trailer1_id = data['trailer1_name'] ?? '';
          trailer2_id = data['trailer2_name'] ?? '';
          dolly_id = data['dolly_name'] ?? '';
          motogenerador_1 = data['motogenerador_1_name'] ?? '';
          motogenerador_2 = data['motogenerador_2_name'] ?? '';
          estado_maniobra = data['estado_maniobra'] ?? '';
          misDatos = (data['contenedores_ligados'] as List<dynamic>)
              .map((jsonItem) => Record.fromJson(jsonItem))
              .toList();
        });
      } else {
        print('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error12: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool todosVerdaderos(Map<String, bool> mapa) {
    for (var valor in mapa.values) {
      if (valor != true) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: widget.color_view,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              ClipPath(
                child: Container(
                  color: widget.color_view,
                  height: MediaQuery.of(context).size.height * .4,
                ),
              ),
              Positioned(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maniobra M-${widget.id_maniobra}',
                            style: const TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                          Text(
                            'Inicio programado: ${formatFecha(inicio_programado)}',
                            style: const TextStyle(
                                fontSize: 30, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipo asignado',
                              style: TextStyle(
                                  color: widget.color_view, fontSize: 40),
                            ),
                            ResponsiveGridRow(
                              children: [
                                if (operador_id != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Operador',
                                        operador_id,
                                        'assets/operador.png',
                                      ),
                                    ),
                                  ),
                                if (vehicle_id != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Vehiculo',
                                        vehicle_id,
                                        'assets/car.png',
                                      ),
                                    ),
                                  ),
                                if (trailer1_id != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Remolque 1',
                                        trailer1_id,
                                        'assets/remolque.png',
                                      ),
                                    ),
                                  ),
                                if (trailer2_id != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Remolque 2',
                                        trailer2_id,
                                        'assets/remolque.png',
                                      ),
                                    ),
                                  ),
                                if (dolly_id != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Dolly',
                                        dolly_id,
                                        'assets/remolque.png',
                                      ),
                                    ),
                                  ),
                                if (motogenerador_1 != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Motogenerador 1',
                                        motogenerador_1,
                                        'assets/generador.png',
                                      ),
                                    ),
                                  ),
                                if (motogenerador_2 != '')
                                  ResponsiveGridCol(
                                    xs: 12,
                                    md: 6,
                                    lg: 3,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      height: 100,
                                      alignment: Alignment(0, 0),
                                      child: estructura(
                                        'Motogenerador 2',
                                        motogenerador_2,
                                        'assets/generador.png',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if ((estado_maniobra == 'activa' &&
                                    tipo_maniobra == 'retiro') ||
                                (estado_maniobra == 'borrador' &&
                                    tipo_maniobra == 'ingreso') ||
                                (tipo_maniobra == 'local') ||
                                (tipo_maniobra == 'resguardo'))
                              Text(
                                'Contenedores',
                                style: TextStyle(
                                    fontSize: 40, color: widget.color_view),
                              ),
                            if ((estado_maniobra == 'activa' &&
                                    tipo_maniobra == 'retiro') ||
                                (estado_maniobra == 'borrador' &&
                                    tipo_maniobra == 'ingreso') ||
                                (tipo_maniobra == 'local') ||
                                (tipo_maniobra == 'resguardo'))
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Card(
                                  elevation: 0,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Referencia contenedor',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Referencia contenedor 2',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Validar',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ],
                                    rows: misDatos.map((record) {
                                      mapa[record.id] ??= false;

                                      return DataRow(
                                        selected: mapa[record.id]!,
                                        cells: <DataCell>[
                                          DataCell(
                                            Text(
                                              record.x_reference,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              record.x_reference_2 != 'null'
                                                  ? record.x_reference_2
                                                  : '',
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Checkbox(
                                              activeColor: widget.color_view,
                                              checkColor: Colors.white,
                                              value: mapa[record.id],
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  mapa[record.id] = value!;
                                                });

                                                setState(() {
                                                  if (todosVerdaderos(mapa)) {
                                                    todosTrue = true;
                                                  } else {
                                                    todosTrue = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Wrap(children: [
          if (todosTrue == true)
            FloatingActionButton.extended(
              backgroundColor: widget.color_view,
              label: const Text(
                "Siguiente",
                style: TextStyle(color: Colors.white, fontSize: 40),
              ),
              onPressed: () async {
                if (estado_maniobra == 'borrador') {
                  bool resultado = await comprobarDisponibilidadUnidades();
                  if (!resultado) {
                    return;
                  }
                }

                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => checklist_maniobra(
                      id_maniobra: widget.id_maniobra,
                      tipo_maniobra: tipo_maniobra,
                      estado_maniobra: estado_maniobra,
                      color_view: widget.color_view,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.navigate_next,
                color: Colors.white,
                size: 45,
              ),
            ),
        ]));
  }

  Widget estructura(String titulo, String vehiculoId, String imagen) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 23, 23, 23)
        : Colors.grey.shade100;

    return InkWell(
      onTap: () {
        setState(() {
          if (mapa[titulo] == true) {
            mapa[titulo] = false;
          } else {
            mapa[titulo] = true;
          }
        });

        setState(() {
          if (todosVerdaderos(mapa)) {
            todosTrue = true;
          } else {
            todosTrue = false;
          }
        });
      },
      child: AnimatedContainer(
        width: 600,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: mapa[titulo] == true ? myTextColor : Colors.grey.shade100,
          border: Border.all(
            color:
                mapa[titulo] == true ? widget.color_view : Colors.grey.shade300,
            width: mapa[titulo] == true ? 2.0 : 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: Image.asset(
                    imagen,
                    height: 40,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Product Sans'),
                    ),
                    Text(
                      vehiculoId,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}
