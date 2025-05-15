import 'package:flutter/material.dart';

import 'checklist_estructura.dart';

class Panel_flota extends StatefulWidget {
  final String id_viaje;
  final Map<String, dynamic> id_flota;
  final String tipo_flota;
  final String tipo_checklist;

  Panel_flota({
    super.key,
    required this.id_viaje,
    required this.id_flota,
    required this.tipo_flota,
    required this.tipo_checklist,
  });

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel_flota>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 1,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.blue[700],
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      title: Text(
                        widget.id_flota.isNotEmpty
                            ? widget.id_flota['name'].toString()
                            : 'Vehículo',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'Product Sans'),
                      ),
                    ),
                  ];
                },
                body: Center(
                    child: Checklist_flota(
                  id_viaje: widget.id_viaje,
                  id_flota: widget.id_flota,
                  tipo_flota: widget.tipo_flota,
                  tipo_checklist: widget.tipo_checklist,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
