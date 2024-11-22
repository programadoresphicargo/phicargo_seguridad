import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Conexion/Conexion.dart';
import '../maniobras/unidades.dart';

Future<List<Item>> fetchOperadores() async {
  final response = await http.post(
      Uri.parse('${conexion}viajes/checklist/buscador/getOperadores.php'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}
