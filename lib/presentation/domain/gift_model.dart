
class GiftItem {
  final int id;
  final String name;
  final String photo;
  final int userId;

  GiftItem({required this.id, required this.name, required this.photo, required this.userId});

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      userId: json['id_user'],
    );
  }
}