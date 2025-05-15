class Item {
  final String id;
  final String title;

  Item({required this.id, required this.title});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      title: json['name'],
    );
  }

  @override
  String toString() => title;
}
