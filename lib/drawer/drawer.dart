import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../login/login_screen.dart';
import '../maniobras/principal.dart';
import '../viaje/pagina_principal.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  void borrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('id_usuario');
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          Container(
            color: Color.fromARGB(255, 0, 79, 199),
            child: CupertinoActionSheetAction(
              onPressed: () {},
              child: const Column(
                children: [
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Product Sans',
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '¿Estas seguro de que quieres cerrar sesión?',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: CupertinoActionSheetAction(
              child: const Text(
                'Confirmar',
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Product Sans',
                    color: Color.fromARGB(255, 0, 79, 199)),
              ),
              onPressed: () {
                borrarSesion();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Product Sans',
                  color: Color.fromARGB(255, 0, 79, 199))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Material(
        color: Color.fromARGB(255, 0, 79, 199),
        child: ListView(
          children: <Widget>[
            buildHeader(),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  buildMenuItem(
                    text: 'Viajes',
                    icon: 'assets/car.png',
                    onClicked: () => selectedItem(context, 0),
                    icon_size: 50,
                  ),
                  buildMenuItem(
                    text: 'Maniobras',
                    icon: 'assets/conta2.jpg',
                    onClicked: () => selectedItem(context, 1),
                    icon_size: 40,
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white70),
                  const SizedBox(height: 10),
                  buildMenuItem(
                    text: 'Cerrar sesión',
                    icon: 'assets/car.png',
                    onClicked: () => _showActionSheet(context),
                    icon_size: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() => Container(
        padding: padding.add(EdgeInsets.symmetric(vertical: 30)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/phicargo.png',
              height: 80,
              color: Colors.white,
            ),
          ],
        ),
      );

  Widget buildMenuItem({
    required String text,
    required String icon,
    required double icon_size,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;

    return ListTile(
      leading: ImageIcon(
        AssetImage(icon),
        color: Colors.white,
        size: icon_size,
      ),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Viajes(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MyTabBarApp(),
        ));
        break;
    }
  }
}
