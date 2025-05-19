import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../Conexion/Conexion.dart';

class ImageData {
  final String id;
  final String imageUrl;

  ImageData({required this.id, required this.imageUrl});
}

class imagen_detallada_maniobra extends StatelessWidget {
  final ImageData imageData;

  imagen_detallada_maniobra({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencia'),
      ),
      body: Center(
        child: Hero(
          tag: 'imageHero${imageData.id}',
          child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.white),
              initialScale: PhotoViewComputedScale.contained,
              basePosition: Alignment.center,
              gaplessPlayback: false,
              customSize: MediaQuery.of(context).size,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered,
              imageProvider: NetworkImage(
                '${conexion}maniobras_evidencias/${imageData.imageUrl}',
              )),
        ),
      ),
    );
  }
}
