import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'package:phicargo_seguridad/maniobras/detalle_maniobra.dart';
import '../metodos/convertir_fecha.dart';

class tablaManiobras extends StatefulWidget {
  String estado_maniobra;
  int vehicle_id;
  Color color_view;

  tablaManiobras(
      {super.key,
      required this.estado_maniobra,
      required this.vehicle_id,
      required this.color_view});

  @override
  _tablaManiobrasState createState() => _tablaManiobrasState();
}

class _tablaManiobrasState extends State<tablaManiobras> {
  Future<List<dynamic>> fetchData({int? vehicleIdFiltro}) async {
    String apiUrl = OdooApi();
    try {
      final uri = Uri.parse('$apiUrl/maniobras/estado/')
          .replace(queryParameters: {'estado': widget.estado_maniobra});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (vehicleIdFiltro != 0) {
          final filtrados = jsonData.where((item) {
            return item["vehicle_id"] == vehicleIdFiltro;
          }).toList();

          return filtrados;
        }

        return jsonData;
      } else {
        throw Exception('Error al cargar los datos');
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 23, 23, 23)
        : Colors.white;

    const TextStyle cellStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
    );

    const TextStyle cellStyleCol = TextStyle(
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
            padding: const EdgeInsets.all(8),
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
                  child: FutureBuilder<List<dynamic>>(
                    future: fetchData(vehicleIdFiltro: widget.vehicle_id),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: widget.color_view,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cargando datos...',
                                  style: TextStyle(
                                      fontSize: 26, color: widget.color_view),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(
                            child: Text(
                              'No existen resultados',
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        );
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
                                  columns: const [
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
                                                id_maniobra: item['id_maniobra']
                                                    .toString(),
                                                color_view: widget.color_view,
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
                                          SizedBox(
                                            width: 130,
                                            child: Badge(
                                              padding: const EdgeInsets.all(6),
                                              backgroundColor:
                                                  widget.color_view,
                                              largeSize: 20,
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Inter'),
                                              textColor: Colors.white,
                                              label: Text(
                                                item['unidad'] ?? 'N/A',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              isLabelVisible: true,
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(
                                            item['nombre_operador'] ?? 'N/A',
                                            style: cellStyle)),
                                        DataCell(Text(item['terminal'] ?? 'N/A',
                                            style: cellStyle)),
                                        DataCell(Text(
                                            item['tipo_maniobra'] ?? 'N/A',
                                            style: cellStyle)),
                                        DataCell(
                                          Text(
                                              formatFecha(
                                                  item['inicio_programado']),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
