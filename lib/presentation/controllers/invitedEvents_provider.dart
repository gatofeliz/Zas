import 'dart:async';

import 'package:flutter/material.dart';
import '../domain/event_model.dart';

class InvitedEventsProvider extends ChangeNotifier {
  List<EventItem> _invitedEventList = [];
  late StreamController<List<EventItem>> _eventsController;

  InvitedEventsProvider() {
    _eventsController = StreamController<List<EventItem>>.broadcast();
    _invitedEventList = [];
    updateInvitedEventList([]);
  }

  List<EventItem> get invitedEventList => _invitedEventList;

  Stream<List<EventItem>> get eventsStream => _eventsController.stream;

  List<int> getInvitedEventIds() {
    return _invitedEventList.map((event) => event.id).toList();
  }

  set invitedEventList(List<EventItem> events) {
    _invitedEventList = events;
    _eventsController.add(_invitedEventList);
    notifyListeners();
  }

  void updateInvitedEventList(List<EventItem> newList) {
    invitedEventList = List.from(newList);
    _eventsController.add(_invitedEventList);
  }

  @override
  void dispose() {
    _eventsController.close();
    super.dispose();
  }
}
