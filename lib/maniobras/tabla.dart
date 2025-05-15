import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/maniobras/detalle_maniobra.dart';

import '../Conexion/Conexion.dart';
import '../metodos/convertir_fecha.dart';

class tabla_maniobras extends StatefulWidget {
  @override
  String estado_maniobra;
  String unidad;
  Color color_view;

  tabla_maniobras(
      {super.key,
      required this.estado_maniobra,
      required this.unidad,
      required this.color_view});

  _tabla_maniobrasState createState() => _tabla_maniobrasState();
}

class _tabla_maniobrasState extends State<tabla_maniobras> {
  late Future<List<dynamic>> _data;
  void initState() {
    super.initState();
    _data = fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    String ruta = 'modulo_maniobras/control/tabla.php';
    final startTime = DateTime.now();

    try {
      final response = await http.post(
        Uri.parse(conexion + ruta),
        body: {
          'estado_maniobra': widget.estado_maniobra,
          'unidad': widget.unidad,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Error al cargar los datos');
      }
    } finally {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Tiempo de respuesta: ${duration.inSeconds} s');
      print('Tiempo de respuesta: ${duration.inMilliseconds} mls');
    }
  }

  Future refresh() async {
    setState(() {
      _data = fetchData();
    });
  }

  void _onRowTap(Map<String, dynamic> rowData, String tipo, String operador,
      String terminal, String inicio_programado, String programado_usuario) {
    print('Tapped on row with data: $rowData');
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => detalle_maniobra(
          id_maniobra: rowData['id'].toString(),
          color_view: widget.color_view,
        ),
      ),
    )
        .then((result) {
      if (result != null) {
        setState(() {
          _data = fetchData();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? Color.fromARGB(255, 23, 23, 23)
        : Colors.white;

    final TextStyle cellStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
    );

    final TextStyle cellStyleCol = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w800,
      fontSize: 16,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: myTextColor,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20.0,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: RefreshIndicator(
                      onRefresh: refresh,
                      backgroundColor: Colors.blue,
                      color: const Color(0xFFF2F4FC),
                      child: FutureBuilder<List<dynamic>>(
                        future: fetchData(),
                        builder:
                            (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: widget.color_view,
                            ));
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('No hay datos disponibles'));
                          } else {
                            return LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      columnSpacing: 16.0,
                                      columns: [
                                        DataColumn(
                                            label: Text(
                                          'ID Maniobra',
                                          style: cellStyleCol,
                                        )),
                                        DataColumn(
                                            label: Text('Vehiculo',
                                                style: cellStyleCol)),
                                        DataColumn(
                                            label: Text('Operador',
                                                style: cellStyleCol)),
                                        DataColumn(
                                            label: Text('Terminal',
                                                style: cellStyleCol)),
                                        DataColumn(
                                            label: Text('Tipo de maniobra',
                                                style: cellStyleCol)),
                                        DataColumn(
                                            label: Text('Inicio Programado',
                                                style: cellStyleCol)),
                                      ],
                                      rows: snapshot.data!.map((item) {
                                        return DataRow(
                                          onSelectChanged: (selected) {
                                            if (selected != null && selected) {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      detalle_maniobra(
                                                    id_maniobra:
                                                        item['id_maniobra']
                                                            .toString(),
                                                    color_view:
                                                        widget.color_view,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          cells: [
                                            DataCell(Text(
                                                'M-${item['id_maniobra']}',
                                                style: cellStyle)),
                                            DataCell(
                                              Container(
                                                width: 130,
                                                child: Badge(
                                                  padding: EdgeInsets.all(6),
                                                  backgroundColor:
                                                      widget.color_view,
                                                  largeSize: 20,
                                                  textStyle: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Inter'),
                                                  textColor: Colors.white,
                                                  label: Text(
                                                    item['unidad'] ?? 'N/A',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  isLabelVisible: true,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(
                                                item['nombre_operador'] ??
                                                    'N/A',
                                                style: cellStyle)),
                                            DataCell(Text(
                                                item['terminal'] ?? 'N/A',
                                                style: cellStyle)),
                                            DataCell(Text(
                                                item['tipo_maniobra'] ?? 'N/A',
                                                style: cellStyle)),
                                            DataCell(
                                              Text(
                                                  formatFecha(item[
                                                      'inicio_programado']),
                                                  style: cellStyle),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
