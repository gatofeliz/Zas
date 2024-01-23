import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../controllers/events_provider.dart';
import '../controllers/user_provider.dart';
import '../domain/event_model.dart';
import 'widgets/eventdetailsowner_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<EventItem> eventList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final dio = Dio();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final url = 'https://zasok.com/api/eventList/${userProvider.userId}';

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer ${userProvider.userToken}'},
        ),
      );

      if (response.statusCode == 200) {
        print(response.data['event']);
        final List<dynamic> events = response.data['event'];
        eventProvider.updateEventList(
          events.map((event) => EventItem.fromJson(event)).toList(),
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Mis Eventos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                return ListView.builder(
                  itemCount: eventProvider.eventList.length,
                  itemBuilder: (context, index) {
                    final EventItem event = eventProvider.eventList[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsScreen(event: event),
                          ),
                        );
                      },
                      child: SizedBox(
                        height: 150,
                        child: Card(
                          color: const Color.fromARGB(255, 252, 235, 255),
                          child: ListTile(
                            title: Text('Nombre del Evento: ${event.name}'),
                            subtitle:
                                Text('Fecha del evento: ${event.timedate}'),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
