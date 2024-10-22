import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../alerta/alerta.dart';
import '../conexion/conexion.dart';
import '../menu/menu.dart';
import 'responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usuario = TextEditingController();
  final TextEditingController contrasena = TextEditingController();
  @override
  Widget build(BuildContext context) {
    void guardarSesion(id_usuario) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('id_usuario', id_usuario);
    }

    Future<void> _login() async {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      String user = usuario.text;
      String password = contrasena.text;
      final dynamic data;
      var response;

      try {
        // Envía la solicitud HTTP para la autenticación
        response = await http.post(
          Uri.parse('${conexion}gestion_viajes/checklist/login/login.php'),
          body: {'usuario': user, 'password': password},
        );

        if (response.statusCode == 200) {
          data = json.decode(response.body);
          print(response.body);
          if (data.containsKey('error')) {
            Navigator.of(context).pop();
            final snackBar = SnackBar(
              backgroundColor: const Color.fromARGB(255, 154, 4, 4),
              content: Text('Error al iniciar sesión: ' + response.body),
              action: SnackBarAction(
                label: 'Descartar',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            print('User found:');
            print(data);

            // Access specific data fields
            final idUsuario = data['id_usuario'];
            final usuario = data['usuario'];
            final nombre = data['nombre'];
            final tipo = data['tipo'];

            print('ID: $idUsuario');
            print('Username: $usuario');
            print('Name: $nombre');
            print('Type: $tipo');
            guardarSesion(idUsuario);

            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              CupertinoPageRoute<dynamic>(
                builder: (BuildContext context) => Menu(
                  pagina: 0,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          Navigator.of(context).pop();
          print('Error');
          error(
              'Error',
              response.body.toString(),
              const Icon(
                Icons.error_outline_sharp,
                color: Colors.white,
              ),
              context);
        }
      } catch ($e) {
        Navigator.of(context).pop();
        error(
            'Error',
            response.body,
            const Icon(
              Icons.error_outline_sharp,
              color: Colors.white,
            ),
            context);
      }
    }

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          children: [
            ResponsiveWidget.isSmallScreen(context)
                ? const SizedBox()
                : Expanded(
                    child: Stack(
                      children: [
                        _backgroundImage(),
                        _backgroundGradient(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35, right: 10),
                              child: SimpleShadow(
                                opacity: 0.6,
                                color: Color.fromARGB(255, 22, 22, 22),
                                offset: Offset(5, 5),
                                sigma: 7,
                                child: Image.network(
                                  "https://phi-cargo.com/wp-content/uploads/2021/05/logo-phicargo-vertical.png",
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                            SizedBox(height: 90),
                          ],
                        )
                      ],
                    ),
                  ),
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 22, 22, 22),
                padding: EdgeInsets.all(30),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (ResponsiveWidget.isSmallScreen(context))
                          Image.network(
                            "https://phi-cargo.com/wp-content/uploads/2021/05/logo-phicargo-vertical.png",
                            color: const Color.fromARGB(255, 255, 255, 255),
                            height: 180,
                          ),
                        SizedBox(height: height * 0.02),
                        const Text(
                          'Bienvenido, Ingresa tus credenciales para acceder \na tu cuenta.',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: height * 0.064),
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Usuario',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Color.fromARGB(255, 30, 30, 30),
                          ),
                          child: TextFormField(
                            controller: usuario,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.person),
                                ),
                                labelStyle: TextStyle(color: Colors.white),
                                hintText: 'Ingresa tu usuario',
                                hintStyle:
                                    const TextStyle(color: Colors.white)),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: height * 0.014),
                        const Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Contraseña',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: const Color.fromARGB(255, 30, 30, 30),
                          ),
                          child: TextFormField(
                              controller: contrasena,
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.remove_red_eye),
                                  ),
                                  prefixIcon: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.key),
                                  ),
                                  hintText: 'Ingresa tu contraseña',
                                  hintStyle:
                                      const TextStyle(color: Colors.white)),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: height * 0.05),
                        ElevatedButton(
                          onPressed: () {
                            _login();
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100.0, vertical: 15.0),
                            minimumSize: const Size(double.infinity,
                                0), // Asegura el ancho completo
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _backgroundGradient extends StatelessWidget {
  Color background = Color.fromARGB(255, 22, 22, 22);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                  background.withOpacity(0.1),
                ])),
          ),
        )
      ],
    );
  }
}

class _backgroundImage extends StatelessWidget {
  final List<String> imgList = [
    'assets/mio.jpg',
    'assets/R2.jpg',
    'assets/fondo4.jpg',
    'assets/fondo.jpg',
    'assets/13.jpg',
    'assets/EEE.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height * 0.9;
              return CarouselSlider(
                options: CarouselOptions(
                  height: height,
                  viewportFraction: .5,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayCurve: Curves.easeOutSine,
                  enlargeFactor: 0.2,
                ),
                items: imgList
                    .map((item) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                item,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 22, 22, 22),
                                  Color.fromARGB(255, 22, 22, 22)
                                      .withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),
        Expanded(flex: 2, child: Container()),
      ],
    );
  }
}
