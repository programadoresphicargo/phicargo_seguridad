import 'package:flutter/material.dart';

import '../drawer/drawer.dart';
import '../maniobras/principal.dart';
import '../viaje/pagina_principal.dart';

class Menu extends StatefulWidget {
  int pagina;
  @override
  Menu({required this.pagina});
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Viajes(), MyTabBarApp()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.pagina;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color myTextColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color.fromARGB(255, 23, 23, 23);

    return Scaffold(
      drawer: NavigationDrawerWidget(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  groupAlignment: 0,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _onItemTapped(index);
                    });
                  },
                  leading: FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 0, 112, 234),
                    elevation: 0,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const ImageIcon(
                      AssetImage(
                        'assets/logito.png',
                      ),
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  destinations: <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: ImageIcon(
                        AssetImage("assets/car.png"),
                        color: myTextColor,
                        size: 50,
                      ),
                      label: Text('Viajes'),
                    ),
                    NavigationRailDestination(
                      icon: ImageIcon(
                        AssetImage("assets/conta2.jpg"),
                        color: myTextColor,
                        size: 40,
                      ),
                      label: Text('Maniobras'),
                    ),
                  ],
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            );
          } else {
            return Scaffold(
              body: _pages[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                elevation: 0,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/car.png"),
                      color: Colors.black,
                      size: 50,
                    ),
                    label: 'Viajes',
                  ),
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage("assets/conta2.jpg"),
                      color: Colors.black,
                      size: 40,
                    ),
                    label: 'Maniobras',
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
