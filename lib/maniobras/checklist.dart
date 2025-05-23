import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'dart:convert';
import '../Alertas/alerta.dart';
import '../Validador/validador.dart';
import '../alerta/alerta.dart';
import '../conexion/conexion.dart';
import '../menu/menu.dart';
import '../Viajes/elementos.dart';
import 'fotos.dart';

class checklist_maniobra extends StatefulWidget {
  @override
  String id_maniobra;
  String tipo_maniobra;
  String estado_maniobra;
  Color color_view;
  checklist_maniobra(
      {super.key,
      required this.id_maniobra,
      required this.tipo_maniobra,
      required this.estado_maniobra,
      required this.color_view});
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<checklist_maniobra> {
  String apiUrl = OdooApi();
  List<dynamic> records = [];
  List<Elementos> selectedCheckboxValues = [];
  List<TextEditingController> inputControllers = [];
  bool _showFab = true;
  bool isLoading = false;

  Future<void> getChecklist() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
          Uri.parse('${conexion}modulo_maniobras/app/checklist_maniobra.php'),
          body: {
            'id_maniobra': widget.id_maniobra,
          });
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          records = jsonData;

          for (int i = 0; i < records.length; i++) {
            String id_elemento;
            String elemento;
            num? estado;
            String observacion;

            id_elemento = records[i]['id_elemento'].toString();
            elemento = records[i]['nombre_elemento'];

            if (estado == 'borrador') {
              if (records[i].containsKey('estado_salida')) {
                estado = records[i]['estado_salida'] == '1' ? 1 : 0;
              } else {
                estado = null;
              }

              if (records[i]['observacion_salida'] != null) {
                observacion = records[i]['observacion_salida'];
              } else {
                observacion = '';
              }
              inputControllers.add(TextEditingController(
                  text: records[i]['observacion_salida']));
            } else {
              if (records[i]['estado_entrada'] != null) {
                estado = records[i]['estado_entrada'] == '1' ? 1 : 0;
              } else {
                estado = null;
              }

              if (records[i]['observacion_entrada'] != null) {
                observacion = records[i]['observacion_entrada'];
              } else {
                observacion = '';
              }
              inputControllers.add(TextEditingController(
                  text: records[i]['observacion_entrada']));
            }
            selectedCheckboxValues.add(Elementos(
              id_elemento: id_elemento,
              elemento: elemento,
              estado: estado,
              observaciones: observacion,
            ));
          }

          for (int i = 0; i < selectedCheckboxValues.length; i++) {
            final item = selectedCheckboxValues[i];
            print('Elemento $i:');
            print('ID elemento: ${item.id_elemento}');
            print('Nombre elemento: ${item.elemento}');
            print('estado: ${item.estado}');
            print('observacion: ${item.observaciones}');
          }

          for (var controller in inputControllers) {
            //print('aol:' + controller.text);
          }
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> activarManiobra(String idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$apiUrl/maniobras/reportes_estatus_maniobras/envio_estatus/'),
        body: {
          'id_maniobra': widget.id_maniobra,
          'id_estatus': '255',
          'id_usuario': idUsuario,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == "success") {
          alerta_success(
            'Proceso exitoso',
            data['message'],
            const Icon(Icons.check, color: Colors.white),
            context,
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Menu(pagina: 1)),
            (route) => false,
          );
        } else {
          alerta(
            'Mensaje',
            data['message'] ?? 'Ocurrió un error inesperado.',
            const Icon(Icons.error, color: Colors.white),
            context,
          );
        }
      } else {
        alerta(
          'Error de red',
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          const Icon(Icons.wifi_off, color: Colors.white),
          context,
        );
      }
    } catch (e) {
      alerta(
        'Error',
        'Error al activar maniobra: $e',
        const Icon(Icons.warning, color: Colors.white),
        context,
      );
    }
  }

  Future<void> finalizarManiobra(String idUsuario) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$apiUrl/maniobras/reportes_estatus_maniobras/envio_estatus/'),
        body: {
          'id_maniobra': widget.id_maniobra,
          'id_estatus': '256',
          'id_usuario': idUsuario,
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data['status'] == "success") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Menu(pagina: 1)),
              (route) => false,
            );
          } else {
            error(
              'Mensaje',
              data['message'] ?? 'No se pudo finalizar la maniobra.',
              const Icon(Icons.error, color: Colors.white),
              context,
            );
          }
        } catch (_) {
          error(
            'Error inesperado',
            response.body,
            const Icon(Icons.warning, color: Colors.white),
            context,
          );
        }
      } else {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      error(
        'Error de red',
        'No se pudo finalizar la maniobra. Detalle: $e',
        const Icon(Icons.wifi_off, color: Colors.white),
        context,
      );
    }
  }

  Future<void> guardarChecklistManiobra(array, idUsuario) async {
    final response;
    try {
      response = await http.post(
          Uri.parse(
              '${conexion}modulo_maniobras/app/guardar_checklist_maniobra.php'),
          body: {
            'id_maniobra': widget.id_maniobra,
            'id_usuario': idUsuario,
            'checklist': array.toString(),
          });
      if (response.statusCode == 200) {
        if (response.body == '1') {
          if (widget.estado_maniobra == 'borrador') {
            activarManiobra(idUsuario);
          } else if (widget.estado_maniobra == 'activa') {
            finalizarManiobra(idUsuario);
          } else {
            print(widget.estado_maniobra);
          }
          final snackBar = SnackBar(
            backgroundColor: const Color.fromARGB(255, 9, 91, 157),
            content: const Text(
              'Información guardada correctamente.',
              style: TextStyle(fontSize: 30),
            ),
            action: SnackBarAction(
              label: 'Descartar',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          final snackBar = SnackBar(
            content: Text(response.body),
            duration: Duration(seconds: 10), // Duración del Snackbar
            action: SnackBarAction(
              label: 'Descartar',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (e) {
      final snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Text('Se produjo una excepción: $e'),
        action: SnackBarAction(
          label: 'Descartar',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    getChecklist();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 23, 23, 23)
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color_view,
        title: Text(
          widget.estado_maniobra == 'borrador'
              ? 'Checklist de salida de equipo'
              : 'Checklist de reingreso de equipo',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ), // Cambia este icono a tu elección
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
          child: Column(
            children: [
              isLoading == true
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: widget.color_view,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Cargando checklist',
                              style: TextStyle(
                                  color: widget.color_view, fontSize: 30),
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(
                        columnSpacing: 10,
                        dividerThickness: 0,
                        showBottomBorder: false,
                        headingRowColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return widget.color_view;
                          },
                        ),
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Inspección',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )),
                          DataColumn(
                              label: Text(
                            'Correcto',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )),
                          DataColumn(
                              label: Text(
                            'Incorrecto',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )),
                          DataColumn(
                            label: Text('Evidencia',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Observaciones',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          selectedCheckboxValues.length,
                          (index) {
                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (index.isEven) {
                                    return myTextColor!;
                                  }
                                  return myTextColor;
                                },
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    (selectedCheckboxValues[index].elemento),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                DataCell(
                                  Radio<num>(
                                    activeColor: widget.color_view,
                                    value: 1,
                                    groupValue:
                                        selectedCheckboxValues[index].estado,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCheckboxValues[index].estado =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                                DataCell(
                                  Radio<num>(
                                    value: 0,
                                    activeColor:
                                        const Color.fromARGB(255, 192, 10, 10),
                                    groupValue:
                                        selectedCheckboxValues[index].estado,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCheckboxValues[index].estado =
                                            value!;
                                      });
                                    },
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      color: widget.color_view,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          isDismissible: true,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return menu_fotos_maniobras(
                                              id_maniobra: widget.id_maniobra,
                                              tipo: widget.tipo_maniobra,
                                              id_elemento:
                                                  selectedCheckboxValues[index]
                                                      .id_elemento,
                                              nombre_elemento:
                                                  selectedCheckboxValues[index]
                                                      .elemento,
                                              estado: widget.estado_maniobra,
                                            );
                                          });
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
                      ).animate().fadeIn())
            ],
          ),
        ),
      ),
      floatingActionButton: Wrap(
        children: [
          AnimatedSlide(
            offset: _showFab ? Offset.zero : Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showFab ? 1 : 0,
              child: FloatingActionButton.extended(
                backgroundColor: widget.color_view,
                onPressed: () {
                  bool comprobacion = true;

                  List<Map<String, dynamic>> jsonDataList = [];

                  for (int i = 0; i < records.length; i++) {
                    num? estado = selectedCheckboxValues[i].estado;
                    if (estado != null && (estado == 0 || estado == 1)) {
                      Map<String, dynamic> jsonData = {
                        'nombre_elemento': records[i]['id_elemento'],
                        'estado': estado,
                        'observacion': inputControllers[i].text,
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
                            guardarChecklistManiobra(jsonBody, userId);
                          },
                        );
                      },
                    );
                  } else {
                    const snackBar = SnackBar(
                      backgroundColor: Color.fromARGB(255, 154, 4, 4),
                      content: Text(
                        'Por favor, asegúrate de seleccionar una opción en cada una de las revisiones.\nNo olvides completar todos los campos obligatorios.',
                        style: TextStyle(fontSize: 30),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                label: const Text('Guardar',
                    style: TextStyle(color: Colors.white, fontSize: 40)),
                icon: const Icon(
                  Icons.save,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
