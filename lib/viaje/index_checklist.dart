import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Conexion/Conexion.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:ui' as ui;

import '../Validador/validador.dart';
import 'contenedor/panel_contenedor.dart';
import 'custodia/comprobar_contenedor_checklist.dart';
import 'custodia/custodia.dart';
import 'flota/comprobar_contenedor_checklist.dart';
import 'flota/expanded.dart';
import 'galeria/galeria.dart';
import '../menu/menu.dart';
import 'contenedor/comprobar_contenedor_checklist.dart';
import 'package:responsive_grid/responsive_grid.dart';

class Record {
  final String id;
  final String name;
  final String x_reference;
  final String x_medida_bel;

  Record(
      {required this.id,
      required this.name,
      required this.x_reference,
      required this.x_medida_bel});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'].toString(),
      name: json['name'].toString(),
      x_reference: json['x_reference'].toString(),
      x_medida_bel: json['x_medida_bel'].toString(),
    );
  }
}

class viaje extends StatefulWidget {
  @override
  final String id_viaje;
  String estado;
  String tipo_checklist;

  viaje(
      {required this.id_viaje,
      required this.estado,
      required this.tipo_checklist});
  State<viaje> createState() => _viajeState();
}

class _viajeState extends State<viaje> {
  Map<String, bool> mapa = {};

  bool todosTrue = false;

  String name = '';
  List<dynamic> employee_id = [];
  List<dynamic> vehicle_id = [];
  List<dynamic> trailer1_id = [];
  List<dynamic> trailer2_id = [];
  List<dynamic> dolly_id = [];
  List<dynamic> x_motogenerador_1 = [];
  List<dynamic> x_motogenerador_2 = [];
  bool custodia = false;

  bool todosVerdaderos(Map<String, bool> mapa) {
    print(mapa);
    for (var valor in mapa.values) {
      if (valor != true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(255, 154, 4, 4),
              title: const Text(
                'Atención',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              content: const Text(
                  'Debes completar el llenado de los checklists de todos los equipos para poder iniciar el viaje.',
                  style: TextStyle(fontSize: 30, color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Descartar',
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return false;
      }
    }
    return true;
  }

  Future<void> getViaje(String id_viaje) async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/odoo/getViaje.php'),
      body: {'id_viaje': id_viaje},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        print(data);
        name = data[0]['name']?.toString() ?? '';
        vehicle_id = data[0]['vehicle_id'] is List ? data[0]['vehicle_id'] : [];
        trailer1_id =
            data[0]['trailer1_id'] is List ? data[0]['trailer1_id'] : [];
        trailer2_id =
            data[0]['trailer2_id'] is List ? data[0]['trailer2_id'] : [];
        dolly_id = data[0]['dolly_id'] is List ? data[0]['dolly_id'] : [];
        employee_id =
            data[0]['employee_id'] is List ? data[0]['employee_id'] : [];
        x_motogenerador_1 = data[0]['x_motogenerador_1'] is List
            ? data[0]['x_motogenerador_1']
            : [];
        x_motogenerador_2 = data[0]['x_motogenerador_2'] is List
            ? data[0]['x_motogenerador_2']
            : [];
      });
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> getCustodia(String id_viaje) async {
    try {
      final response = await http.post(
        Uri.parse('${conexion}gestion_viajes/odoo/comprobar_custodia.php'),
        body: {'id_viaje': id_viaje},
      );

      if (response.statusCode == 200) {
        setState(() {
          final data = json.decode(response.body);
          if (data[0]['x_custodia_bel'] == 'yes') {
            custodia = true;
          } else {
            custodia = false;
          }
        });
      }
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Exception custodia: $e'),
          ),
        );
      });
    }
  }

  Future<List<Record>> getCartas(String id_viaje) async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/odoo/getCartas.php'),
      body: {'id_viaje': id_viaje},
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData.map((record) => Record.fromJson(record)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  Future<void> disponibilidad_equipos() async {
    final response = await http.post(
      Uri.parse(
          '${conexion}gestion_viajes/disponibilidad/disponibilidad_viaje.php'),
      body: {
        'id': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> disponibilidad_contenedores() async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/disponibilidad/contenedores.php'),
      body: {
        'id': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<String> comprobar_operador() async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/odoo/comprobar_operador.php'),
      body: {
        'id': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
      if (response.body == '1') {
        return '1';
      } else {
        return 'No se puede iniciar el viaje porque el nombre del conductor no concuerda con el operador programado en las cartas porte ligadas, favor de actualizar la información en Odoo e intentar iniciar nuevamente.';
      }
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> liberar_contenedores() async {
    final response = await http.post(
      Uri.parse(
          '${conexion}gestion_viajes/disponibilidad/liberar_contenedores.php'),
      body: {
        'id': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<String> comprobar_correos() async {
    final response = await http.post(
      Uri.parse(
          '${conexion}gestion_viajes/correos/ligar_correos/correos_ligados_comprobacion.php'),
      body: {
        'id_viaje': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
      if (response.body == '1') {
        const snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text('Viaje con correos ligados.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return '1';
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 154, 4, 4),
              title: const Text('Advertencia',
                  style: TextStyle(color: Colors.white, fontSize: 30)),
              content: const Text(
                'El viaje no cuenta con direcciones de correo electrónico asociadas.\nPor favor, notifíquelo al área de monitoreo para poder proceder.',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        return '0';
      }
    } else {
      const snackBar = SnackBar(
        duration: Duration(seconds: 10),
        backgroundColor: Color.fromARGB(255, 154, 4, 4),
        content: Text('Error al obtener la información del servidor'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> desmontar_equipo() async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/disponibilidad/desmontar.php'),
      body: {
        'id': widget.id_viaje,
      },
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> iniciar_viaje(String id_usuario) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Lottie.asset('assets/car.json', height: 120),
        );
      },
    );

    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/algoritmos/envio_manual.php'),
      body: {
        'id': widget.id_viaje,
        'id_usuario': id_usuario,
        'id_status': '1',
        'status_nombre': 'Inicio de viaje'
      },
    );

    if (response.statusCode == 200) {
      if (response.body == '1') {
        const snackBar = SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Viaje iniciado correctamente',
            style: TextStyle(fontSize: 30),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          widget.estado = 'ruta';
        });

        disponibilidad_contenedores();
        disponibilidad_equipos();

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => Menu(
                pagina: 0,
              ),
            ),
            (route) => false);
      } else {
        final snackBar = SnackBar(
          content: Text(response.body),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(
        content: Text(response.body),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      throw Exception('Failed to load data from server');
    }
  }

  Future<void> finalizar_viaje(String id_usuario) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Procesando'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Por favor, espere...'),
            ],
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse('${conexion}gestion_viajes/algoritmos/envio_manual.php'),
        body: {
          'id': widget.id_viaje,
          'id_usuario': id_usuario,
          'id_status': '103',
          'status_nombre': 'Viaje finalizado'
        },
      );

      if (response.statusCode == 200) {
        if (response.body == '1') {
          const snackBar = SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Viaje finalizado correctamente.',
              style: TextStyle(fontSize: 30),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            widget.estado = 'Finalizado';
          });
          liberar_contenedores();
          desmontar_equipo();

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => Menu(
                  pagina: 0,
                ),
              ),
              (route) => false);
        } else {
          final snackBar = SnackBar(
            content: Text(response.body),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        throw Exception('Failed to load data from server');
      }
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Error: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<bool> comprobar_firma(vehiculo_id, String estado_checklist) async {
    bool estado;
    String ruta = 'gestion_viajes/checklist/firma/comprobar_firma.php';

    final response = await http.post(
      Uri.parse(conexion + ruta),
      body: {
        'viaje_id': widget.id_viaje,
        'tipo_checklist': widget.tipo_checklist,
      },
    );

    if (response.statusCode == 200) {
      if (response.body == '1') {
        estado = true;
      } else {
        estado = false;
      }
      return estado;
    } else {
      throw Exception('Failed to load data from server');
    }
  }

  @override
  void initState() {
    print('estado viaje' + widget.estado);
    super.initState();
    getViaje(widget.id_viaje);
    getCartas(widget.id_viaje);
    comprobar_firma(widget.id_viaje, widget.tipo_checklist);
    if (widget.tipo_checklist == 'salida') {
      getCustodia(widget.id_viaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist de ${widget.tipo_checklist}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 60, color: Colors.blue[700]),
                  ),
                ],
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operador asignado',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        employee_id.length > 1 ? employee_id[1].toString() : '',
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w100),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                'Equipo asignado',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.blue[700],
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ResponsiveGridRow(
                    children: [
                      if (vehicle_id.length > 1 &&
                          vehicle_id[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                            height: 100,
                            alignment: Alignment(0, 0),
                            child: card_flota(
                              'Vehiculo',
                              widget.id_viaje,
                              vehicle_id,
                              'Tractor',
                              widget.tipo_checklist,
                              'assets/car.png',
                            ),
                          ),
                        ),
                      if (trailer1_id.length > 1 &&
                          trailer1_id[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                            height: 100,
                            alignment: Alignment(0, 0),
                            child: card_flota(
                              'Remolque #1',
                              widget.id_viaje,
                              trailer1_id,
                              'Remolque',
                              widget.tipo_checklist,
                              'assets/remolque.png',
                            ),
                          ),
                        ),
                      if (trailer2_id.length > 1 &&
                          trailer2_id[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                            height: 100,
                            alignment: Alignment(0, 0),
                            child: card_flota(
                              'Remolque #2',
                              widget.id_viaje,
                              trailer2_id,
                              'Remolque',
                              widget.tipo_checklist,
                              'assets/remolque.png',
                            ),
                          ),
                        ),
                      if (dolly_id.length > 1 &&
                          dolly_id[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                            height: 100,
                            alignment: Alignment(0, 0),
                            child: card_flota(
                              'Dolly',
                              widget.id_viaje,
                              dolly_id,
                              'Remolque',
                              widget.tipo_checklist,
                              'assets/dolly.png',
                            ),
                          ),
                        ),
                      if (x_motogenerador_1.length > 1 &&
                          x_motogenerador_1[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                              height: 100,
                              alignment: Alignment(0, 0),
                              child: card_flota(
                                  'Motogenerador 1',
                                  widget.id_viaje,
                                  x_motogenerador_1,
                                  'Motogenerador',
                                  widget.tipo_checklist,
                                  'assets/generador.png')),
                        ),
                      if (x_motogenerador_2.length > 1 &&
                          x_motogenerador_2[1].toString().isNotEmpty)
                        ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: Container(
                              height: 100,
                              alignment: Alignment(0, 0),
                              child: card_flota(
                                  'Motogenerador 2',
                                  widget.id_viaje,
                                  x_motogenerador_2,
                                  'Motogenerador',
                                  widget.tipo_checklist,
                                  'assets/generador.png')),
                        ),
                    ],
                  ),
                ),
              ),
              Text(
                'Contenedores',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 40,
                    color: Colors.blue[700]),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Desplazamiento horizontal
                child: Card(
                  child: FutureBuilder<List<Record>>(
                    future: getCartas(widget.id_viaje),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No hay datos disponibles'));
                      }

                      return DataTable(
                        columnSpacing: 16,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Carta porte',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Contenedor',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Medida',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Inspeccionado',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                        rows: snapshot.data!.map((record) {
                          return DataRow(
                            onSelectChanged: (bool? selected) {
                              if (selected != null && selected) {
                                Navigator.of(context)
                                    .push(
                                  CupertinoPageRoute(
                                    builder: (context) => Panel_contenedor(
                                      id_viaje: widget.id_viaje,
                                      id_cp: [record.id, record.x_reference],
                                      tipo_checklist: widget.tipo_checklist,
                                    ),
                                  ),
                                )
                                    .then((result) {
                                  if (result != null) {
                                    getViaje(widget.id_viaje);
                                    getCartas(widget.id_viaje);
                                  }
                                });
                              }
                            },
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  record.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
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
                                  record.x_medida_bel,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              DataCell(
                                FutureBuilder<bool>(
                                  future: comprobar_checklist_contenedor(
                                      widget.id_viaje,
                                      record.id,
                                      widget.tipo_checklist,
                                      context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                        size: 30,
                                      );
                                    } else if (snapshot.hasData) {
                                      mapa[record.id] = snapshot.data!;
                                      return Icon(
                                        snapshot.data!
                                            ? Icons.check
                                            : Icons.close,
                                        color: snapshot.data!
                                            ? Colors.green
                                            : Colors.red,
                                        size: 40,
                                      );
                                    } else {
                                      return const Icon(
                                        Icons.close,
                                        size: 40,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
              Card(
                  child: Padding(
                padding: EdgeInsets.all(18),
                child: ResponsiveGridRow(
                  children: [
                    ResponsiveGridCol(
                      lg: 6,
                      md: 6,
                      sm: 12,
                      child: Container(
                        height: 100,
                        alignment: Alignment(0, 0),
                        child: firma(
                          widget.id_viaje,
                          widget.tipo_checklist,
                        ),
                      ),
                    ),
                    if (widget.tipo_checklist == 'salida' && custodia == true)
                      ResponsiveGridCol(
                        lg: 6,
                        md: 6,
                        sm: 12,
                        child: Container(
                          height: 100,
                          alignment: Alignment(0, 0),
                          child: custodia_widget('Servicio con custodia',
                              widget.id_viaje, widget.tipo_checklist),
                        ),
                      ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
      floatingActionButton: Wrap(
        children: [
          if (widget.estado == 'Disponible')
            FloatingActionButton.extended(
              backgroundColor: Colors.green,
              onPressed: () async {
                String comprobacion_correos = await comprobar_correos();
                print(comprobacion_correos);
                if (comprobacion_correos == '1') {
                  if (todosVerdaderos(mapa)) {
                    String comparacion_operador = await comprobar_operador();
                    if (comparacion_operador == '1') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return PinValidatorDialog(
                            onPinVerified: (userId) {
                              print('Usuario verificado: $userId');
                              iniciar_viaje(userId);
                            },
                          );
                        },
                      );
                    } else {
                      final snackBar = SnackBar(
                        duration: Duration(seconds: 10),
                        backgroundColor: const Color.fromARGB(255, 154, 4, 4),
                        content: Text(comparacion_operador),
                        action: SnackBarAction(
                          label: 'Descartar',
                          onPressed: () {},
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
                }
              },
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              label: const Text(
                'Iniciar viaje',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          if (widget.estado == 'ruta' && widget.tipo_checklist == 'reingreso' ||
              widget.estado == 'planta' &&
                  widget.tipo_checklist == 'reingreso' ||
              widget.estado == 'retorno' &&
                  widget.tipo_checklist == 'reingreso')
            FloatingActionButton.extended(
              backgroundColor: Color.fromARGB(255, 154, 4, 4),
              onPressed: () {
                if (todosVerdaderos(mapa)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return PinValidatorDialog(
                        onPinVerified: (userId) {
                          print('Usuario verificado: $userId');
                          finalizar_viaje(userId);
                        },
                      );
                    },
                  );
                }
              },
              icon: const Icon(
                Icons.stop,
                color: Colors.white,
                size: 40,
              ),
              label: const Text(
                'Finalizar viaje',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget custodia_widget(String title, String id_viaje, String tipo_checklist) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: comprobar_custodia(id_viaje),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        Color fondo = Colors.grey.shade100;
        Color borde = Colors.white;
        String custodia = '';
        String empresa_custodia = '';
        String nombres_custodios = '';
        String unidad = '';
        String custodia_validada = '';

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var dataList = snapshot.data!;
            bool estado = true;

            for (var data in dataList) {
              custodia = data['x_custodia_bel'];

              if (custodia == 'yes') {
                borde = Colors.blue;
                mapa[title] = true;
                empresa_custodia = data['x_empresa_custodia'].toString() ?? '';
                nombres_custodios = data['x_nombre_custodios'].toString() ?? '';
                unidad = data['x_datos_unidad'].toString() ?? '';
                custodia_validada =
                    data['x_custodia_validada']?.toString() ?? '';
                if (custodia_validada == 'true') {
                  fondo = Colors.blue.shade100;
                  borde = Colors.blue;
                } else {
                  fondo = Colors.grey.shade100;
                  borde = Colors.white;
                }
              } else {
                mapa[title] = false;
              }
            }
          } else if (snapshot.hasError) {
            print('Ocurrió un error: ${snapshot.error}');
          }
        }

        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(CupertinoPageRoute(
              builder: (context) => Custodia(
                id_viaje: widget.id_viaje,
                empresa_custodia: empresa_custodia,
                nombre_custodios: nombres_custodios,
                datos_vehiculo: unidad,
              ),
            ))
                .then((result) {
              if (result != null) {
                getViaje(widget.id_viaje);
                getCartas(widget.id_viaje);
                comprobar_custodia(widget.id_viaje);
              }
            });
          },
          child: Card(
            color: fondo,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: borde,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    child: Image.asset(
                      'assets/icon/police.png',
                      width: 100,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget card_flota(String title, String id_viaje, List<dynamic> id_flota,
      String tipo_flota, String tipo_checklist, String ruta) {
    return FutureBuilder<bool>(
      future: comprobar_checklist_flota(
          id_viaje, id_flota[0].toString(), tipo_checklist, context),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Color fondo = Colors.grey.shade100;
        Color borde = Colors.white;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            bool? estado = snapshot.data;
            if (estado == true) {
              fondo = Colors.blue.shade200;
              borde = Colors.blue;
              mapa[title] = true;
            } else {
              fondo = Colors.grey.shade100;
              borde = Colors.white;
              mapa[title] = false;
            }
          } else if (snapshot.hasError) {
            print('Ocurrió un error: ${snapshot.error}');
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(CupertinoPageRoute(
              builder: (context) => Panel_flota(
                  id_viaje: id_viaje,
                  id_flota: id_flota,
                  tipo_flota: tipo_flota,
                  tipo_checklist: tipo_checklist),
            ))
                .then((result) {
              if (result != null) {
                getViaje(widget.id_viaje);
                getCartas(widget.id_viaje);
              }
            });
          },
          child: Card(
            color: fondo,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: borde,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    minRadius: 30,
                    maxRadius: 30,
                    child: Image.asset(
                      ruta,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Colors.blue[700], fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        id_flota[1].toString(),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w200),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<ImageData>> fetchImageList() async {
    final response = await http.post(
        Uri.parse('${conexion}gestion_viajes/checklist/firma/cargar_firma.php'),
        body: {
          'viaje_id': widget.id_viaje,
          'tipo_checklist': widget.tipo_checklist,
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => ImageData(
                id: item['id_elemento'].toString(),
                imageUrl: item['ruta'].toString(),
              ))
          .toList();
    } else {
      throw Exception('Failed to load image data');
    }
  }

  Future<void> _refreshImageData() async {
    fetchImageList();
  }

  Future<void> _showSignatureDialog(BuildContext context) async {
    final _sign = GlobalKey<SignatureState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Firmas'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 1000,
                  height: MediaQuery.of(context).size.height,
                  child: Signature(key: _sign),
                ),
                Container(
                  width: 300,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.blue.shade100,
                  padding: EdgeInsets.all(20),
                  child: RefreshIndicator(
                      onRefresh: _refreshImageData,
                      child: FutureBuilder<List<ImageData>>(
                        future: fetchImageList(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Aún no hay imagenes.'),
                            );
                          } else {
                            return GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                crossAxisCount: 2,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Hero(
                                  tag: 'imageHero${snapshot.data![index].id}',
                                  child: Image.network(
                                    '${conexion}checklist_evidencias/${snapshot.data![index].imageUrl}',
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              onPressed: () async {
                final sign = _sign.currentState;
                final image = await sign!.getData();
                print(image);
                var data =
                    await image!.toByteData(format: ui.ImageByteFormat.png);
                sign!.clear();
                final encoded = base64.encode(data!.buffer.asUint8List());
                _sendImageToServer(data!.buffer.asUint8List());
                Navigator.pop(dialogContext); // Cerrar el AlertDialog
              },
              child: const Text(
                'Guardar firma',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendImageToServer(Uint8List imageBytes) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id_usuario');

      final url = '${conexion}gestion_viajes/checklist/firma/guardar_firma.php';
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['id_viaje'] = widget.id_viaje;
      request.fields['id_usuario'] = id.toString();
      request.fields['tipo_checklist'] = widget.tipo_checklist;

      request.files.add(http.MultipartFile('imageBytes',
          http.ByteStream.fromBytes(imageBytes), imageBytes.length,
          filename: 'image.jpg'));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Firma enviada exitosamente');
        final responseString = await response.stream.bytesToString();
        if (responseString == 'Imagen guardada exitosamente') {
          final snackbar = SnackBar(
            backgroundColor: Colors.blue[700],
            content: Text(
              responseString,
              style: const TextStyle(fontSize: 30),
            ),
            duration: const Duration(seconds: 5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          setState(() {
            mapa['firma'] = true;
          });
        } else {
          setState(() {
            mapa['firma'] = false;
          });
        }
      } else {
        print('Error al enviar la firma');
      }
    } catch (e) {}
  }

  Widget firma(String id_viaje, String tipo_checklist) {
    ThemeData theme = Theme.of(context);

    return FutureBuilder<bool>(
      future: comprobar_firma(vehicle_id, widget.tipo_checklist),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        Color fondo = Colors.grey.shade100;
        Color borde = Colors.white;

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            bool? estado = snapshot.data;
            if (estado == true) {
              fondo = theme.brightness == Brightness.dark
                  ? Colors.blue
                  : const Color.fromRGBO(187, 222, 251, 1);
              borde = Colors.blue;
              mapa['firma'] = true;
              print(mapa);
            } else {
              fondo = theme.brightness == Brightness.dark
                  ? const Color.fromARGB(255, 23, 23, 23)
                  : Colors.grey.shade100;

              borde = Colors.white;
              mapa['firma'] = false;
              print(mapa);
            }
          } else if (snapshot.hasError) {
            print('Ocurrió un error: ${snapshot.error}');
          }
        }

        return GestureDetector(
          onTap: () {
            _showSignatureDialog(context);
          },
          child: Card(
            color: fondo,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: borde,
                width: 2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/firma.png',
                    height: 40,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Firma del operador',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
