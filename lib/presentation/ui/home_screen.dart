// invited_events_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../controllers/invitedEvents_provider.dart';
import '../controllers/user_provider.dart';
import '../domain/event_model.dart';
import 'eventdetails_screen.dart';

class InvitedEventsScreen extends StatefulWidget {
  const InvitedEventsScreen({Key? key}) : super(key: key);

  @override
  _InvitedEventsScreenState createState() => _InvitedEventsScreenState();
}

class _InvitedEventsScreenState extends State<InvitedEventsScreen> {
  List<EventItem> invitedEventList = [];

  @override
  void initState() {
    super.initState();
    getInvitedEvents();
  }

  Future<void> getInvitedEvents() async {
    final dio = Dio();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final invitedEventsProvider =
        Provider.of<InvitedEventsProvider>(context, listen: false);
    final url = 'https://zasok.com/api/eventAccepted/${userProvider.userId}';
    print(userProvider.userId);

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer ${userProvider.userToken}'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> invitedEvents = response.data['events'];

        invitedEventsProvider.updateInvitedEventList(
          invitedEvents.map((event) => EventItem.fromJson(event)).toList(),
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
        title: const Text('Eventos'),
        actions: [
          IconButton(
            onPressed: () {
              _showJoinEventDialog(
                  context, Provider.of<UserProvider>(context, listen: false));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<EventItem>>(
              stream: Provider.of<InvitedEventsProvider>(context).eventsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text('Aun no te unes a un evento'));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final List<EventItem> events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aun no te has unido a un evento',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final EventItem event = events[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvitedEventDetails(event: event),
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
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showJoinEventDialog(
      BuildContext context, UserProvider userProvider) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    TextEditingController codeController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unirse a un evento'),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa el código del evento:'),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Código',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final code = codeController.text;
                await joinEvent(code, userProvider.userId);
                print('Unirse al evento con código: ${codeController.text}');
                Navigator.pop(context);
              },
              child: const Text('Unirme'),
            ),
          ],
        );
      },
    );
  }

  Future<void> joinEvent(String code, int? attenderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final dio = Dio();
    const url = 'https://zasok.com/api/join';

    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer ${userProvider.userToken}'},
        ),
        data: {
          "code": code,
          "attendeed_id": attenderId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('Respuesta del servidor: $responseData');
        getInvitedEvents();
      } else {
        print('Error en la petición. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición: $e');
    }
  }
}
