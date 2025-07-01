import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewExample extends StatefulWidget {
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late InAppWebViewController webViewController;

  Future<bool> solicitarPermisos(List<Permission> permisos) async {
    Map<Permission, PermissionStatus> estados = await permisos.request();
    bool todosConcedidos = estados.values.every((status) => status.isGranted);
    if (estados.values.any((status) => status.isPermanentlyDenied)) {
      await openAppSettings();
    }

    return todosConcedidos;
  }

  void verificarPermisos() async {
    bool concedidos = await solicitarPermisos([
      Permission.camera,
      Permission.microphone,
    ]);

    if (concedidos) {
      print("Permisos concedidos");
    } else {
      print("Permisos denegados");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verificarPermisos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            userAgent: "com.phicargo.admin",
            mediaPlaybackRequiresUserGesture: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            allowsInlineMediaPlayback: true,
          ),
          initialUrlRequest: URLRequest(
            url: WebUri('https://phides-client.phicargo-sistemas.online/menu'),
          ),
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      ),
    );
  }
}
