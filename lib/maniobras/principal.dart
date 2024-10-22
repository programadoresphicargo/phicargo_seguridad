import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../metodos/getUnidades.dart';
import 'tabla.dart';
import 'unidades.dart';

class MyTabBarApp extends StatefulWidget {
  @override
  _MyTabBarAppState createState() => _MyTabBarAppState();
}

class _MyTabBarAppState extends State<MyTabBarApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color _appBarColor = const Color.fromARGB(255, 25, 118, 210);
  late Future<List<Item>> items;
  String vehiculo = '';
  Item? selectedItem;

  @override
  void initState() {
    super.initState();
    items = fetchItems();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _appBarColor = const Color.fromARGB(255, 25, 118, 210);
        } else {
          _appBarColor = Colors.deepPurple;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control de salidas y entrada de unidades a maniobras',
          style: TextStyle(color: Color.fromARGB(255, 34, 69, 151)),
        ),
        bottom: TabBar(
          isScrollable: true,
          onTap: (index) {
            if (_tabController.previousIndex == index) {
              setState(() {});
            }
          },
          unselectedLabelColor: _appBarColor,
          indicatorColor: _appBarColor,
          labelColor: _appBarColor,
          controller: _tabController,
          labelStyle: TextStyle(fontSize: 30, fontFamily: 'Product Sans'),
          tabs: const [
            Tab(
              text: 'Salidas programadas',
            ),
            Tab(
              text: 'Maniobras activas',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<Item>>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return DropdownSearch<Item>(
                    popupProps: const PopupProps.menu(showSearchBox: true),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Buscar por unidad",
                      ),
                    ),
                    clearButtonProps: ClearButtonProps(
                      isVisible: true,
                      onPressed: () {
                        setState(() {
                          vehiculo = '';
                          selectedItem =
                              null; // Limpia la selección en el DropdownSearch
                        });
                      },
                    ),
                    items: snapshot.data!,
                    itemAsString: (Item item) => item.title,
                    selectedItem:
                        selectedItem, // Vincula la opción seleccionada con el estado
                    onChanged: (Item? item) {
                      setState(() {
                        selectedItem =
                            item; // Actualiza el estado con la nueva selección
                        vehiculo = item?.id ?? '';
                      });
                    },
                  );
                } else {
                  return Center(child: Text('No se encontraron datos.'));
                }
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                tabla_maniobras(
                  estado_maniobra: 'borrador',
                  unidad: vehiculo,
                  color_view: _appBarColor,
                ),
                tabla_maniobras(
                  estado_maniobra: 'activa',
                  unidad: vehiculo,
                  color_view: _appBarColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
