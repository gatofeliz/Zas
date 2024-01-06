class EventItem {
  final int id;
  final String name;
  final String timedate;
  final String code;
  final int userId;
  final String published;

  EventItem({
    required this.id,
    required this.name,
    required this.timedate,
    required this.code,
    required this.userId,
    required this.published,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'],
      name: json['event'],
      timedate: json['timedate'],
      code: json['code'],
      userId: json['user_id'],
      published: json['published'],
    );
  }
}