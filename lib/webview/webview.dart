import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewExample extends StatefulWidget {
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample>
    with WidgetsBindingObserver {
  late InAppWebViewController webViewController;
  bool permisosConcedidos = false;
  bool permisosCargados = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    verificarPermisos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      verificarPermisos(); // Volver a verificar si vino de configuración
    }
  }

  Future<void> verificarPermisos() async {
    final statusCam = await Permission.camera.status;
    final statusMic = await Permission.microphone.status;

    if (statusCam.isGranted && statusMic.isGranted) {
      setState(() {
        permisosConcedidos = true;
        permisosCargados = true;
      });
    } else {
      final result = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final concedidos = result.values.every((status) => status.isGranted);

      if (!concedidos &&
          (await Permission.camera.isPermanentlyDenied ||
              await Permission.microphone.isPermanentlyDenied)) {
        await openAppSettings();
      }

      setState(() {
        permisosConcedidos = concedidos;
        permisosCargados = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !permisosCargados
          ? Center(child: CircularProgressIndicator())
          : permisosConcedidos
              ? SafeArea(
                  child: InAppWebView(
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowFileAccessFromFileURLs: true,
                      allowUniversalAccessFromFileURLs: true,
                      allowsInlineMediaPlayback: true,
                      userAgent: "com.phicargo.admin",
                    ),
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                          'https://phides-client.phicargo-sistemas.online/menu'),
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
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Se requieren permisos para cámara y micrófono.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          verificarPermisos();
                        },
                        child: Text("Solicitar permisos"),
                      )
                    ],
                  ),
                ),
    );
  }
}
