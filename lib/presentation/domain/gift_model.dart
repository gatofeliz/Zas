
class GiftItem {
  final int id;
  final String name;
  final String photo;
  final int userId;
  final String confirmated;
  final int? eventId;
  final String? dedicatory;

  GiftItem( {required this.id, required this.name, required this.photo, required this.userId, required this.confirmated,this.eventId, this.dedicatory});

  factory GiftItem.fromJson(Map<String, dynamic> json) {
    return GiftItem(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      confirmated: json['confirmated'],
      userId: json['user_id'],
      eventId: json['event_id'],
      dedicatory: json['dedicatory'],
    );
  }
}