import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'login/login_screen.dart';
import 'menu/menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await verificarSesion();
  await dotenv.load();
  await Permission.camera.request();
  await Permission.microphone.request();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      title: 'Phi Cargo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Product Sans',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Product Sans',
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        hintColor: Colors.amber,
      ),
      themeMode: ThemeMode.light,
      home: isLoggedIn
          ? Menu(
              pagina: 0,
            )
          : LoginScreen(),
    );
  }
}

Future<bool> verificarSesion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}
