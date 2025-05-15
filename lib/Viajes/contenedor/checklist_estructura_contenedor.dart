import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Validador/validador.dart';
import '../../conexion/conexion.dart';
import '../elementos.dart';
import '../galeria/menu_fotos.dart';

class checklist_contenedor extends StatefulWidget {
  late String id_viaje;
  final String id_cp;
  late String tipo_checklist;
  checklist_contenedor(
      {required this.id_viaje,
      required this.id_cp,
      required this.tipo_checklist});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<checklist_contenedor> {
  List<dynamic> records = [];
  List<Elementos> selectedCheckboxValues = [];
  List<TextEditingController> inputControllers = [];
  bool _showFab = true;

  bool todosVerdaderos(Map<String, bool> mapa) {
    for (var valor in mapa.values) {
      if (valor != true) {
        return false;
      }
    }
    return true;
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse(
          '${conexion}viajes/checklist/contenedor/getChecklistContenedor.php'),
      body: {
        'id_viaje': widget.id_viaje,
        'id_cp': widget.id_cp,
        'tipo_checklist': widget.tipo_checklist
      },
    );

    try {
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          records = jsonData;

          for (int i = 0; i < records.length; i++) {
            String id_elemento;
            String elemento;
            num? estado;
            String observaciones;

            id_elemento = records[i]['id_elemento'].toString();
            elemento = records[i]['nombre_elemento'].toString();

            if (records[i].containsKey('estado')) {
              estado = records[i]['estado'].toString() == 'true' ? 1 : 0;
            } else {
              estado = null;
            }

            if (records[i]['observaciones'] != null) {
              observaciones = records[i]['observaciones'].toString();
            } else {
              observaciones = '';
            }
            inputControllers.add(
              TextEditingController(text: records[i]['observaciones']),
            );

            selectedCheckboxValues.add(Elementos(
              id_elemento: id_elemento,
              elemento: elemento,
              estado: estado,
              observaciones: observaciones,
            ));
          }

          for (int i = 0; i < selectedCheckboxValues.length; i++) {
            final item = selectedCheckboxValues[i];
            print('Elemento $i:');
            print('ID elemento: ${item.id_elemento}');
            print('Nombre elemento: ${item.elemento}');
            print('estado: ${item.estado}');
            print('observaciones: ${item.observaciones}');
          }

          for (var controller in inputControllers) {
            print('aol:${controller.text}');
          }
        });
      } else {
        print('Error en la solicitud: Código de estado ${response.statusCode}');
        final snackBar = SnackBar(
          content: Text(response.body),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {},
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error al realizar la solicitud: $e');
      final snackBar = SnackBar(
        content: Text('Error al realizar la solicitud: ${response.body}'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> guardar_checklist_contenedor(array, id_usuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${conexion}viajes/checklist/contenedor/guardarChecklist.php'),
        body: {
          'id_viaje': widget.id_viaje,
          'id_cp': widget.id_cp.toString(),
          'checklist': array.toString(),
          'id_usuario': id_usuario,
          'tipo_checklist': widget.tipo_checklist,
        },
      );

      if (response.statusCode == 200) {
        if (response.body == '1') {
          Navigator.pop(context, true);
          final snackBar = SnackBar(
            backgroundColor: Colors.blue[700],
            content: Text(
              'Información guardada correctamente.${response.body}',
              style: TextStyle(fontSize: 30),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          print(response.body);
          final snackBar = SnackBar(
            backgroundColor: const Color.fromARGB(255, 154, 4, 4),
            content: Text(
              response.body,
              style: const TextStyle(fontSize: 30),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              'Error: Código de estado ${response.statusCode}${response.body}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Ocurrió un error: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? Color.fromARGB(255, 23, 23, 23)
        : Colors.white;

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final ScrollDirection direction = notification.direction;
          setState(() {
            if (direction == ScrollDirection.reverse) {
              _showFab = false;
            } else if (direction == ScrollDirection.forward) {
              _showFab = true;
            }
          });
          return true;
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columnSpacing: 20,
                dividerThickness: 0,
                showBottomBorder: false,
                headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.blueGrey;
                    }
                    return Colors.deepPurple;
                  },
                ),
                columns: const [
                  DataColumn2(
                      label: Text(
                    'Punto a inspeccionar',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  )),
                  DataColumn2(
                      label: Text('Correcto',
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                  DataColumn2(
                      label: Text('Incorrecto',
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                  DataColumn2(
                      label: Text('Evidencia',
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                  DataColumn2(
                      label: Text('Observaciones',
                          style: TextStyle(fontSize: 25, color: Colors.white))),
                ],
                rows: List<DataRow>.generate(
                  selectedCheckboxValues.length,
                  (index) {
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (index.isEven) {
                            return myTextColor!;
                          }
                          return myTextColor;
                        },
                      ),
                      cells: [
                        DataCell(
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: Text(
                              selectedCheckboxValues[index].elemento,
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        DataCell(
                          Radio<num>(
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => Colors.deepPurple),
                            value: 1,
                            groupValue: selectedCheckboxValues[index].estado,
                            onChanged: (value) {
                              setState(() {
                                selectedCheckboxValues[index].estado = value!;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Radio<num>(
                            fillColor: MaterialStateColor.resolveWith(
                                (states) => Colors.deepPurple),
                            value: 0,
                            groupValue: selectedCheckboxValues[index].estado,
                            onChanged: (value) {
                              setState(() {
                                selectedCheckboxValues[index].estado = value!;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.deepPurple),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => BottomSheetContent(
                                    elemento_id: selectedCheckboxValues[index]
                                        .id_elemento,
                                    viaje_id: widget.id_viaje,
                                    tipo_checklist: widget.tipo_checklist,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        DataCell(
                          TextField(
                            controller: inputControllers[index],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1 : 0,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.deepPurple,
            onPressed: () {
              bool comprobacion = true;

              List<Map<String, dynamic>> jsonDataList = [];

              for (int i = 0; i < records.length; i++) {
                num? estado = selectedCheckboxValues[i].estado;
                if (estado != null && (estado == 0 || estado == 1)) {
                  Map<String, dynamic> jsonData = {
                    'id_elemento': records[i]['id_elemento'],
                    'estado': estado,
                    'observaciones': inputControllers[i].text,
                  };
                  jsonDataList.add(jsonData);
                } else {
                  comprobacion = false;
                }
              }

              Map<String, String> headers = {
                'Content-Type': 'application/json'
              };
              String jsonBody = json.encode(jsonDataList);
              if (comprobacion == true) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return PinValidatorDialog(
                      onPinVerified: (userId) {
                        print('Usuario verificado: $userId');
                        guardar_checklist_contenedor(jsonBody, userId);
                      },
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Advertencia',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 40),
                      ),
                      content: const Text(
                        'Por favor, asegúrate de seleccionar una opción en cada una de las revisiones.\nNo olvides completar todos los campos obligatorios.',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w300),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cierra el diálogo
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            label: const Text('Guardar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.w400)),
          ),
        ),
      ),
    );
  }
}
