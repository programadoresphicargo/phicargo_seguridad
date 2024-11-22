import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Conexion/Conexion.dart';
import '../../Validador/validador.dart';
import 'galeria.dart';

class BottomSheetContent extends StatefulWidget {
  String viaje_id;
  String elemento_id;
  String tipo_checklist;
  BottomSheetContent(
      {required this.elemento_id,
      required this.viaje_id,
      required this.tipo_checklist});
  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final picker = ImagePicker();

  List<File> _imageFiles = [];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(
        source: source, maxHeight: 480, maxWidth: 640, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadImages(String id_usuario) async {
    final url =
        Uri.parse('${conexion}viajes/checklist/galeria/guardar_evidencia.php');
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

    request.fields['tipo_checklist'] = widget.tipo_checklist;
    request.fields['viaje_id'] = widget.viaje_id;
    request.fields['elemento_id'] = widget.elemento_id;
    request.fields['id_usuario'] = id_usuario;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      if (responseString == '1') {
        _imageFiles.clear();
        setState(() {
          fetchImageList();
        });
        const snackBar = SnackBar(
          backgroundColor: Colors.deepPurple,
          content: Text(
            'Información guardada correctamente',
            style: TextStyle(color: Colors.white, fontSize: 30),
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
      print('HTTP request failed with status: ${response.statusCode}');
    }
  }

  Future<List<ImageData>> fetchImageList() async {
    final response = await http.post(
        Uri.parse('${conexion}viajes/checklist/galeria/cargar_imagenes.php'),
        body: {
          'viaje_id': widget.viaje_id,
          'elemento_id': widget.elemento_id,
          'tipo_checklist': widget.tipo_checklist,
        });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((item) => ImageData(
                id: item['id_elemento'].toString(),
                imageUrl: item['ruta'].toString(),
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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_imageFiles.isNotEmpty) {
          showDialog(
              context: context,
              builder: (buildcontext) {
                return AlertDialog(
                  title: const Text("Alerta",
                      style:
                          TextStyle(fontFamily: 'Product Sans', fontSize: 22)),
                  content: const Text(
                      "Por favor, guardar las evidencias antes de salir.",
                      style: TextStyle(
                          fontFamily: 'Product Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w100)),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        'Volver y descartar imagenes',
                        style: TextStyle(fontFamily: 'Product Sans'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(fontFamily: 'Product Sans'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Evidencias'),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - 50,
          padding: EdgeInsets.only(top: 6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      crossAxisCount: 7),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ImageDetailPage(
                                          imageData: snapshot.data![index]),
                                    ));
                                  },
                                  child: Hero(
                                    tag: 'imageHero${snapshot.data![index].id}',
                                    child: Image.network(
                                        fit: BoxFit.fill,
                                        '${conexion}checklist_evidencias/${snapshot.data![index].imageUrl}'),
                                  ),
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
          backgroundColor: Colors.deepPurple,
          onPressed: () {
            if (_imageFiles.length > 0) {
              showDialog(
                context: context,
                builder: (context) {
                  return PinValidatorDialog(
                    onPinVerified: (userId) {
                      print('Usuario verificado: $userId');
                      _uploadImages(userId);
                    },
                  );
                },
              );
            } else {
              const snackBar = SnackBar(
                content: Text('Carga imágenes primero.'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          icon: const Icon(
            Icons.send,
            color: Colors.white,
            size: 40,
          ),
          label: const Text(
            'Guardar evidencia',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Product Sans',
                fontSize: 40,
                fontWeight: FontWeight.w100),
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
                return Stack(
                  children: [
                    // Imagen
                    Image.file(_imageFiles[index], fit: BoxFit.cover),
                    // Botón para eliminar
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar borrado'),
          content: Text('¿Estás seguro de que quieres borrar esta imagen?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Borrar'),
              onPressed: () {
                _imageFiles.removeAt(index);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}
