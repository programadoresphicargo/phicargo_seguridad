import 'package:flutter/cupertino.dart';

class ModalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Modal Page'),
      ),
      child: Center(
        child: CupertinoButton(
          child: const Text('Mostrar Modal'),
          onPressed: () {
            _mostrarModal(context);
          },
        ),
      ),
    );
  }

  void _mostrarModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Opciones'),
          message: const Text('Seleccione una opción'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                print('Opción 1 seleccionada');
              },
              child: const Text('Opción 1'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                print('Opción 2 seleccionada');
              },
              child: const Text('Opción 2'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            isDefaultAction: true,
            child: const Text('Cancelar'),
          ),
        );
      },
    );
  }
}
