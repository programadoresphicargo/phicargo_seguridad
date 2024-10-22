import 'package:flutter/material.dart';

import '../flota/checklist_estructura.dart';
import 'checklist_estructura_contenedor.dart';

class Panel_contenedor extends StatefulWidget {
  final String id_viaje;
  final List<dynamic> id_cp;
  final String tipo_checklist;

  Panel_contenedor({
    super.key,
    required this.id_viaje,
    required this.id_cp,
    required this.tipo_checklist,
  });

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel_contenedor>
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
                      backgroundColor: Colors.deepPurple,
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
                        widget.id_cp.isNotEmpty
                            ? widget.id_cp[1].toString()
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
                  child: checklist_contenedor(
                    id_viaje: widget.id_viaje,
                    id_cp: widget.id_cp[0].toString(),
                    tipo_checklist: widget.tipo_checklist,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
