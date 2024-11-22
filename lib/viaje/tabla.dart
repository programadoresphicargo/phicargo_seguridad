import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

import '../Conexion/Conexion.dart';
import '../metodos/convertir_fecha.dart';
import 'index_checklist.dart';

class CustomDataTable extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> dataFuture;
  final Future<void> Function() onRefresh;

  const CustomDataTable({
    Key? key,
    required this.dataFuture,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        backgroundColor: Colors.blue,
        color: Color(0xFFF2F4FC),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/car.json', width: 300),
                    const Text('Obteniendo viajes, espere un momento...'),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(Colors.blue.shade100),
                    sortColumnIndex: _currentSortColumn,
                    sortAscending: _isAscending,
                    showCheckboxColumn: false,
                    showBottomBorder: false,
                    columns: _buildColumns(snapshot.data!),
                    rows: _buildRows(snapshot.data!),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  final TextStyle cellStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
  );

  List<DataColumn> _buildColumns(List<Map<String, dynamic>> data) {
    return [
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Referencia',
          style: cellStyle,
        ),
        onSort: (columnIndex, _) =>
            _sortColumn(columnIndex, 'referencia', data),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Unidad',
          style: cellStyle,
        ),
        onSort: (columnIndex, _) => _sortColumn(columnIndex, 'unidad', data),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text('Operador', style: cellStyle),
        onSort: (columnIndex, _) =>
            _sortColumn(columnIndex, 'nombre_operador', data),
      ),
      DataColumn2(
        size: ColumnSize.S,
        label: Text(
          'Ruta',
          style: cellStyle,
        ),
        onSort: (columnIndex, _) => _sortColumn(columnIndex, 'route_id', data),
      ),
      DataColumn2(
        size: ColumnSize.L,
        label: Text(
          'Salida',
          style: cellStyle,
        ),
        onSort: (columnIndex, _) =>
            _sortColumn(columnIndex, 'x_inicio_programado', data),
      ),
    ];
  }

  List<DataRow> _buildRows(List<Map<String, dynamic>> data) {
    return data.map((data) {
      return DataRow(
        onSelectChanged: (_) => _onRowTap(data),
        cells: [
          DataCell(
            Container(
              width: 130,
              child: Badge(
                padding: EdgeInsets.all(6),
                backgroundColor: Colors.blue,
                largeSize: 20,
                textStyle: const TextStyle(
                    fontSize: 5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Product Sans'),
                textColor: Colors.white,
                label: Text(
                  data['referencia'].toString(),
                  style: cellStyle,
                ),
                isLabelVisible: true,
              ),
            ),
          ),
          DataCell(Text(
            data['unidad'].toString(),
            style: cellStyle,
          )),
          DataCell(Text(
            data['nombre_operador'].toString(),
            style: cellStyle,
          )),
          DataCell(Text(
            data['ruta'].toString(),
            style: cellStyle,
          )),
          DataCell(
            Text(
              formatDateTime(data['date_start']),
              style: cellStyle,
            ),
          ),
        ],
      );
    }).toList();
  }

  void _sortColumn(
      int columnIndex, String columnName, List<Map<String, dynamic>> data) {
    setState(() {
      _currentSortColumn = columnIndex;
      if (_isAscending) {
        _isAscending = false;
        data.sort((a, b) => b[columnName].compareTo(a[columnName]));
      } else {
        _isAscending = true;
        data.sort((a, b) => a[columnName].compareTo(b[columnName]));
      }
    });
  }

  void _onRowTap(Map<String, dynamic> data) async {
    await getInfoViaje(data['travel_id'].toString());
    await getCartas(data['travel_id'].toString());
    _showDialog(
      context,
      data['travel_id'].toString(),
      data['referencia'].toString(),
      data['unidad'].toString(),
      data['nombre_operador'].toString(),
      data['date_start'].toString(),
      data['estado_viaje'].toString(),
    );
  }

  List<Map<String, dynamic>> _viajeData = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _viajeContenedores = [];
  bool _isLoading2 = false;

  Future<void> getCartas(String id_viaje) async {
    setState(() {
      _isLoading2 = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${conexion}viajes/odoo/getCartas.php'),
        body: {'id_viaje': id_viaje},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _viajeContenedores = List<Map<String, dynamic>>.from(data);
          _isLoading2 = false;
        });
      } else {
        setState(() {
          _isLoading2 = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading2 = false;
      });
    }
  }

  Future<void> getInfoViaje(String id_viaje) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${conexion}viajes/odoo/getViaje.php'),
        body: {'id_viaje': id_viaje},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _viajeData = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context, String id_viaje, String referencia,
      String unidad, String operador, String inicio_programado, String estado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingresar checklist de viaje'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Referencia de viaje',
                    style: TextStyle(fontSize: 20, color: Colors.blue[700])),
                Text(
                  referencia,
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('Unidad',
                    style: TextStyle(fontSize: 20, color: Colors.blue[700])),
                Text(
                  unidad,
                  style: TextStyle(fontSize: 30),
                ),
                Text('Inicio programado',
                    style: TextStyle(fontSize: 20, color: Colors.blue[700])),
                Text(
                  inicio_programado,
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('Operador asignado',
                    style: TextStyle(fontSize: 20, color: Colors.blue[700])),
                Text(operador, style: TextStyle(fontSize: 30)),
                const SizedBox(
                  height: 10,
                ),
                Text('Información previa',
                    style: TextStyle(fontSize: 20, color: Colors.blue[700])),
                Container(
                  child: Card(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _viajeData.isEmpty
                            ? const Center(child: Text('No data available'))
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                        label: Text('Referencia de viaje')),
                                    DataColumn(label: Text('Vehículo')),
                                    DataColumn(label: Text('Remolque 1')),
                                    DataColumn(label: Text('Remolque 2')),
                                    DataColumn(label: Text('Dolly')),
                                    DataColumn(label: Text('Moto Gen 1')),
                                    DataColumn(label: Text('Moto Gen 2')),
                                  ],
                                  rows: _viajeData.map((viaje) {
                                    return DataRow(cells: [
                                      DataCell(Text(viaje['name'] ?? 'N/A')),
                                      DataCell(Text(viaje['vehicle_id'] is List
                                          ? (viaje['vehicle_id'] as List)[1]
                                          : 'N/A')),
                                      DataCell(Text(viaje['trailer1_id'] is List
                                          ? (viaje['trailer1_id'] as List)[1]
                                          : 'N/A')),
                                      DataCell(Text(viaje['trailer2_id'] is List
                                          ? (viaje['trailer2_id'] as List)[1]
                                          : 'N/A')),
                                      DataCell(Text(viaje['dolly_id'] is List
                                          ? (viaje['dolly_id'] as List)[1]
                                          : 'N/A')),
                                      DataCell(Text(
                                          viaje['x_motogenerador_1'] is List
                                              ? (viaje['x_motogenerador_1']
                                                  as List)[1]
                                              : 'N/A')),
                                      DataCell(Text(
                                          viaje['x_motogenerador_2'] is List
                                              ? (viaje['x_motogenerador_2']
                                                  as List)[1]
                                              : 'N/A')),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                  ),
                ),
                Container(
                  child: Card(
                    child: _isLoading2
                        ? const Center(child: CircularProgressIndicator())
                        : _viajeContenedores.isEmpty
                            ? const Center(child: Text('No data available'))
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Contenedores')),
                                  ],
                                  rows: _viajeContenedores.map((viaje) {
                                    return DataRow(cells: [
                                      DataCell(
                                        Text(viaje['x_reference']?.toString() ??
                                            'N/A'),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => viaje(
                                id_viaje: id_viaje,
                                estado: estado,
                                tipo_checklist: 'salida',
                              ),
                            ),
                          );
                        },
                        child: const TransparentImageCard(
                          width: double.infinity,
                          imageProvider: AssetImage('assets/salida2.jpg'),
                          title: Text(
                            'Salida',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (estado == 'retorno')
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => viaje(
                                  id_viaje: id_viaje,
                                  estado: estado,
                                  tipo_checklist: 'reingreso',
                                ),
                              ),
                            );
                          },
                          child: const TransparentImageCard(
                            width: double.infinity,
                            imageProvider: AssetImage('assets/salida.jpg'),
                            title: Text(
                              'Reingreso',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
