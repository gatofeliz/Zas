import 'package:flutter/material.dart';
import '../domain/event_model.dart';

class EventProvider extends ChangeNotifier {
  List<EventItem> _eventList = [];
  List<EventItem> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();

  List<EventItem> get eventList => _eventList;
  List<EventItem> get filteredEvents => _filteredEvents;
  TextEditingController get searchController => _searchController;

  set eventList(List<EventItem> events) {
    _eventList = events;
    filterEvents();
    notifyListeners();
  }

  void filterEvents() {
    final searchTerm = _searchController.text.toLowerCase();

    if (searchTerm.isEmpty) {
      _filteredEvents = List.from(_eventList);
    } else {
      _filteredEvents = _eventList.where((event) {
        return event.name.toLowerCase().contains(searchTerm) ||
            event.timedate.toLowerCase().contains(searchTerm);
      }).toList();
    }

    notifyListeners();
  }

  void updateEventList(List<EventItem> newList) {
    eventList = List.from(newList);
  }

  void updateSearchTerm(String term) {
    _searchController.text = term;
    filterEvents();
  }

  void deleteEvent(int eventId) {
    _eventList.removeWhere((event) => event.id == eventId);
    filterEvents();
    notifyListeners();
  }
}
