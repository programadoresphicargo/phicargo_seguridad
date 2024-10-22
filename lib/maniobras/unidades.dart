import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

import '../Conexion/Conexion.dart';

class Item {
  final String id;
  final String title;

  Item({required this.id, required this.title});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['vehicle_id'],
      title: json['name'],
    );
  }

  @override
  String toString() => title;
}

Future<List<Item>> fetchItems() async {
  final response = await http.post(
    Uri.parse(conexion + 'modulo_maniobras/data/get_flota.php'),
    body: {
      'fleet_type': 'tractor',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Item.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load items');
  }
}
