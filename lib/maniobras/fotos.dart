import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../Conexion/Conexion.dart';
import '../Validador/validador.dart';
import '../Maniobras/galeria.dart';

class menu_fotos_maniobras extends StatefulWidget {
  String id_maniobra;
  String tipo;
  String id_elemento;
  String nombre_elemento;
  String estado;
  menu_fotos_maniobras(
      {super.key,
      required this.id_maniobra,
      required this.tipo,
      required this.id_elemento,
      required this.nombre_elemento,
      required this.estado});
  @override
  State<menu_fotos_maniobras> createState() => _menu_fotos_maniobrasState();
}

class _menu_fotos_maniobrasState extends State<menu_fotos_maniobras> {
  final picker = ImagePicker();

  List<File> _imageFiles = [];
  String estado = '';

  Future<void> consultar_estado() async {
    if (widget.estado == 'borrador') {
      setState(() {
        estado = 'Salida';
      });
    } else if (widget.estado == 'activa') {
      setState(() {
        estado = 'Reingreso';
      });
    }
    print(estado);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
        source: source, maxHeight: 480, maxWidth: 640, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadImages(id_usuario) async {
    final url =
        Uri.parse('${conexion}modulo_maniobras/app/guardar_evidencias.php');
    var request = http.MultipartRequest('POST', url);

    for (int i = 0; i < _imageFiles.length; i++) {
      var stream = http.ByteStream(_imageFiles[i].openRead());
      var length = await _imageFiles[i].length();

      var multipartFile = http.MultipartFile(
        'image[]',
        stream,
        length,
        filename: _imageFiles[i].path.split('/').last,
      );

      request.files.add(multipartFile);
    }

    request.fields['tipo'] = widget.tipo;
    request.fields['id_maniobra'] = widget.id_maniobra;
    request.fields['id_elemento'] = widget.id_elemento;
    request.fields['id_usuario'] = id_usuario.toString();
    request.fields['estado'] = estado;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      if (responseString == '1') {
        _imageFiles.clear();
        setState(() {
          fetchImageList();
        });
        final snackBar = SnackBar(
          backgroundColor: const Color.fromARGB(255, 9, 91, 157),
          content: const Text(
            'Evidencia guardada correctamente',
            style: TextStyle(fontSize: 20),
          ),
          action: SnackBarAction(
            label: 'Descartar',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          fetchImageList();
        });
      } else if (responseString == 'Error uploading image.') {
        final snackBar = SnackBar(
          content: Text(responseString),
          action: SnackBarAction(
            label: 'Descartar',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (responseString == 'Error al subir la imagen.') {
        final snackBar = SnackBar(
          content: Text(responseString),
          action: SnackBarAction(
            label: 'Descartar',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
          backgroundColor: const Color.fromARGB(255, 9, 91, 157),
          content: Text(responseString),
          action: SnackBarAction(
            label: 'Descartar',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(
        content:
            Text('HTTP request failed with status: ${response.statusCode}'),
        action: SnackBarAction(
          label: 'Descartar',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<List<ImageData>> fetchImageList() async {
    final response = await http.post(
        Uri.parse('${conexion}modulo_maniobras/app/cargar_imagenes.php'),
        body: {
          'id_maniobra': widget.id_maniobra,
          'id_elemento': widget.id_elemento,
          'tipo': widget.tipo,
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => ImageData(
                id: item['id_elemento'].toString(),
                imageUrl: item['ruta_archivo'].toString(),
              ))
          .toList();
    } else {
      throw Exception('Failed to load image data');
    }
  }

  Future<void> _refreshImageData() async {
    fetchImageList();
  }

  @override
  void initState() {
    super.initState();
    fetchImageList();
    consultar_estado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height - 50,
        padding: EdgeInsets.only(top: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Añadir evidencias',
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.camera);
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45.0,
                        backgroundColor: Colors.blue,
                        backgroundImage: AssetImage(
                          'assets/camera.png',
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Cámara',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.yellow,
                        radius: 45.0,
                        backgroundImage: AssetImage('assets/galeria.png'),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Galería',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Evidencias de ${widget.nombre_elemento}',
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: RefreshIndicator(
                    onRefresh: _refreshImageData,
                    child: FutureBuilder<List<ImageData>>(
                      future: fetchImageList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Aún no hay imagenes.'),
                          );
                        } else {
                          return GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 4,
                                    crossAxisCount: 4),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          imagen_detallada_maniobra(
                                              imageData: snapshot.data![index]),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'imageHero${snapshot.data![index].id}',
                                  child: Image.network(
                                    '${conexion}maniobras_evidencias/${snapshot.data![index].imageUrl}',
                                    fit: BoxFit.cover,
                                  ),
                                ).animate().fadeIn(),
                              );
                            },
                          );
                        }
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromARGB(255, 9, 91, 157),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return PinValidatorDialog(onPinVerified: (userId) {
                print('Usuario verificado: $userId');
                _uploadImages(userId);
              });
            },
          );
        },
        tooltip: 'Enviar',
        label: const Text(
          'Enviar',
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
        icon: const Icon(
          size: 40,
          Icons.send,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        height: 150,
        color: Color.fromARGB(255, 252, 251, 251),
        child: Container(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                  width: 100,
                  height: 100,
                  child: CupertinoContextMenu(
                      actions: <Widget>[
                        CupertinoContextMenuAction(
                          onPressed: () {
                            _imageFiles.removeAt(index);
                            Navigator.pop(context);
                            setState(() {
                              _imageFiles;
                            });
                          },
                          isDestructiveAction: true,
                          trailingIcon: CupertinoIcons.delete,
                          child: const Text('Borrar'),
                        ),
                      ],
                      child: ColoredBox(
                          color: CupertinoColors.systemYellow,
                          child: Image.file(_imageFiles[index],
                              fit: BoxFit.cover))));
            },
          ),
        ),
      ),
    );
  }
}
