import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:image_card/image_card.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Alertas/update.dart';
import '../Conexion/Conexion.dart';
import '../metodos/getUnidades.dart';
import '../login/login_screen.dart';
import 'package:data_table_2/data_table_2.dart';

import 'index_checklist.dart';
import 'tabla.dart';

class Viajes extends StatefulWidget {
  @override
  _ViajesState createState() => _ViajesState();
}

class _ViajesState extends State<Viajes> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _data;
  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _contenedorController = TextEditingController();
  String estado = 'Disponible';
  late TabController _tabController;

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.post(
      Uri.parse('${conexion}gestion_viajes/checklist/viajes.php'),
      body: {
        'referencia': _referenciaController.text,
        'operador': _operadorController.text,
        'unidad': _unidadController.text,
        'contenedor': _contenedorController.text,
        'estado': get_estado(_tabController.index),
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future refresh() async {
    setState(() {
      _data = fetchData();
    });
  }

  void _tabListener() {
    int currentIndex = _tabController.index;
    print("Índice de la pestaña actual: $currentIndex");
    refresh();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_tabListener);

    final newVersion = NewVersionPlus(
        androidId: 'com.phicargo.admin', androidPlayStoreCountry: "es_ES");

    const simpleBehavior = true;

    if (simpleBehavior) {
      print('buscando version');
      advancedStatusCheck(newVersion);
    }
    super.initState();
    _data = fetchData();
    fetchOperadores();
    UnidadesFetcher.fetchUnidades().then((data) {
      setState(() {
        unidades = data;
      });
    }).catchError((error) {
      // Manejar errores aquí
      print("Error: $error");
    });
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      if (status.localVersion != status.storeVersion) {
        print('NUEVA VERSION DISPONIBLE');

        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
      } else {
        print('MISMA VERSION');
      }
    }
  }

  String get_estado(int value) {
    String result = 'Disponible';
    if (value == 0) {
      result = 'Disponible';
    } else if (value == 1) {
      result = 'retorno';
    } else if (value == 2) {
      result = 'finalizado';
    }
    return result;
  }

  Color getBackgroundColor(String value) {
    if (value == 'Disponible') {
      return Colors.green;
    } else if (value == 'retorno') {
      return Colors.yellow;
    } else if (value == 'Finalizado') {
      return Colors.red;
    } else {
      return Colors.white;
    }
  }

  List<String> operadores = const [];
  List<String> unidades = const [];

  Future<void> fetchOperadores() async {
    final response = await http.get(Uri.parse(
        conexion + 'gestion_viajes/checklist/buscador/getOperadores.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        setState(() {
          operadores =
              data.map((item) => item['nombre_operador'].toString()).toList();
        });
      }
    } else {
      throw Exception('Fallo al cargar los datos desde la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Programación de viajes',
            style: TextStyle(fontSize: 30),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Desplazamiento horizontal
              child: Column(
                children: <Widget>[
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.blue[700],
                    dividerColor: Colors.blue[700],
                    indicatorColor: Colors.blue[700],
                    unselectedLabelStyle: const TextStyle(
                        color: Colors.black, fontFamily: 'Product Sans'),
                    labelStyle: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'Product Sans',
                        fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Viajes a ruta'),
                      Tab(text: 'Viajes de retorno'),
                      Tab(text: 'Viajes finalizados'),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    height: 100.0,
                    child: Row(
                      children: [
                        Container(
                          width: 300,
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                            ),
                            items: operadores,
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Operadores",
                              ),
                            ),
                            selectedItem: _operadorController.text,
                            onChanged: (selectedValue) {
                              print('Valor seleccionado: $selectedValue');
                              setState(() {
                                _operadorController.text =
                                    selectedValue.toString();
                                _data = fetchData();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _operadorController.text = '';
                              _data = fetchData();
                            });
                          },
                        ),
                        Container(
                          width: 200,
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                            ),
                            items: unidades,
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Unidades",
                              ),
                            ),
                            selectedItem: _unidadController.text,
                            onChanged: (selectedValue) {
                              print('Valor seleccionado: $selectedValue');
                              setState(() {
                                _unidadController.text =
                                    selectedValue.toString();
                                _data = fetchData();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _unidadController.text = '';
                              _data = fetchData();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            CustomDataTable(
              dataFuture: _data,
              onRefresh: refresh,
            ),
            CustomDataTable(
              dataFuture: _data,
              onRefresh: refresh,
            ),
            CustomDataTable(
              dataFuture: _data,
              onRefresh: refresh,
            )
          ],
        ),
      ),
    );
  }

  sesion() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        reverse: true, // Invertir el desplazamiento para que el contenido suba
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  void cerrarSesion() async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.remove('isLoggedIn');
                    prefs.remove('id_usuario');
                  }

                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    CupertinoPageRoute<dynamic>(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Ajustar la altura (vertical)
                  minimumSize:
                      Size(double.infinity, 0), // Ajustar el ancho (horizontal)
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Cerrar sesion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
