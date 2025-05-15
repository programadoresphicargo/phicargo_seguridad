import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'dart:convert';
import '../maniobras/unidades.dart';

Future<List<Item>> fetchOperadores() async {
  String apiUrl = OdooApi();
  final response = await http.get(Uri.parse('$apiUrl/drivers/'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}
