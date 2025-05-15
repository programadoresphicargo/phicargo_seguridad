import 'package:http/http.dart' as http;
import 'package:phicargo_seguridad/Api/api.dart';
import 'dart:convert';
import 'unidades.dart';

String apiUrl = OdooApi();

Future<List<Item>> fetchOperadores() async {
  final response = await http.get(Uri.parse('$apiUrl/drivers/'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}

Future<List<Item>> fetchVehiculos() async {
  final uri = Uri.parse('$apiUrl/vehicles/fleet_type/tractor');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}
