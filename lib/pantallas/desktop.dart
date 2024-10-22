import 'package:flutter/material.dart';

import '../viaje/pagina_principal.dart';

class MyDesktopBody extends StatelessWidget {
  const MyDesktopBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // First column
          Expanded(
            child: Column(
              children: [Expanded(child: Viajes())],
            ),
          ),
        ],
      ),
    );
  }
}
