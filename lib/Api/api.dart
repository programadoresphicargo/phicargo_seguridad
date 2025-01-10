import 'package:flutter_dotenv/flutter_dotenv.dart';

String OdooApi() {
  String apiEnv = dotenv.env['API_ENV'] ?? '';

  if (apiEnv == 'produccion') {
    return dotenv.env['API_ODOO_PRODUCCION'] ?? '';
  } else if (apiEnv == 'pruebas') {
    return dotenv.env['API_ODOO_PRUEBAS'] ?? '';
  } else {
    throw Exception('La variable API_ENV no está configurada correctamente');
  }
}
