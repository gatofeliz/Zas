
class GiftItem {
  final int id;
  final String name;
  final String photo;

  GiftItem({required this.id, required this.name, required this.photo});

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
    );
  }
}