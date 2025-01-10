import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:image_card/image_card.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:phicargo_seguridad/buscador/operadores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Alertas/update.dart';
import '../Conexion/Conexion.dart';
import '../maniobras/unidades.dart';
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
  String estado = 'Disponible';
  late TabController _tabController;

  late Future<List<Item>> items;
  String id_unidad = '';
  Item? selectedItem;

  late Future<List<Item>> itemsOperadores;
  String id_operador = '';
  Item? selectedItemOperador;

  Future<List<Map<String, dynamic>>> fetchData() async {
    var response;
    try {
      response = await http.post(
        Uri.parse('${conexion}viajes/checklist/getViajes.php'),
        body: {
          'id_operador': id_operador,
          'id_unidad': id_unidad,
          'estado': get_estado(_tabController.index),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: Text(response.body),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () {
              print('Acción de deshacer ejecutada');
            },
          ),
        ),
      );
      throw Exception('Failed to fetch data: $e');
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
    items = fetchItems();
    itemsOperadores = fetchOperadores();
    _data = fetchData();
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
      result = 'disponible';
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
            preferredSize: const Size.fromHeight(180.0), // Aumenta la altura
            child: Column(
              children: [
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
                  padding: const EdgeInsets.only(top: 10),
                  height: 100.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: FutureBuilder<List<Item>>(
                            future: itemsOperadores,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                return DropdownSearch<Item>(
                                  popupProps: const PopupProps.menu(
                                      showSearchBox: true),
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Buscar por operador",
                                    ),
                                  ),
                                  clearButtonProps: ClearButtonProps(
                                    isVisible: true,
                                    onPressed: () {
                                      setState(() {
                                        id_operador = '';
                                        selectedItemOperador = null;
                                        _data = fetchData();
                                      });
                                    },
                                  ),
                                  items: snapshot.data!,
                                  itemAsString: (Item item) => item.title,
                                  selectedItem: selectedItemOperador,
                                  onChanged: (Item? item) {
                                    setState(() {
                                      selectedItemOperador = item;
                                      id_operador = item?.id ?? '';
                                      _data = fetchData();
                                    });
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text('No se encontraron datos.'));
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: FutureBuilder<List<Item>>(
                            future: items,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                return DropdownSearch<Item>(
                                  popupProps: const PopupProps.menu(
                                      showSearchBox: true),
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText: "Buscar por unidad",
                                    ),
                                  ),
                                  clearButtonProps: ClearButtonProps(
                                    isVisible: true,
                                    onPressed: () {
                                      setState(() {
                                        id_unidad = '';
                                        selectedItem = null;
                                        _data = fetchData();
                                      });
                                    },
                                  ),
                                  items: snapshot.data!,
                                  itemAsString: (Item item) => item.title,
                                  selectedItem: selectedItem,
                                  onChanged: (Item? item) {
                                    setState(() {
                                      selectedItem = item;
                                      id_unidad = item?.id ?? '';
                                      _data = fetchData();
                                    });
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text('No se encontraron datos.'));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      decoration: const BoxDecoration(
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
