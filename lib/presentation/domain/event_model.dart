class EventItem {
  final int id;
  final String name;
  final String timedate;
  final String code;
  final int userId;
  final String published;
  final int eventId;
  final int? giftId; 

  EventItem({
    required this.id,
    required this.name,
    required this.timedate,
    required this.code,
    required this.userId,
    required this.published,
    required this.eventId,
    this.giftId,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'],
      name: json['event'],
      timedate: json['timedate'],
      code: json['code'],
      userId: json['user_id'],
      published: json['published'],
      eventId: json['event_id'],
      giftId: json['gift_id'],
    );
  }
}