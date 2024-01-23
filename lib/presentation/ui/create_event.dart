import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/events_provider.dart';
import '../controllers/navbar_provider.dart';
import '../controllers/user_provider.dart';
import '../domain/event_model.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final TextEditingController eventController = TextEditingController();
  final TextEditingController timedateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: const Text('Crea tu Evento!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: eventController,
              decoration: const InputDecoration(labelText: 'Nombre del Evento'),
            ),
            const SizedBox(height: 50),
            DateTimePicker(
              type: DateTimePickerType.dateTimeSeparate,
              dateMask: 'd MMM, yyyy',
              initialValue: DateTime.now().toString(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              icon: const Icon(Icons.event),
              dateLabelText: 'Fecha',
              timeLabelText: 'Hora',
              onChanged: (val) {
                timedateController.text = val;
              },
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                _createEvent();
                context.go('/principal');
              },
              child: const Text('Crear Evento'),
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() async {
    String eventName = eventController.text;
    String timedate = timedateController.text;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String apiUrl = 'https://zasok.com/api/storeEvent';

    Map<String, dynamic> requestBody = {
      'event': eventName,
      'timedate': timedate,
      'user_id': userProvider.userId,
    };

    if (eventName.isEmpty || timedate.isEmpty) {
      _showToast('Por favor, llena todos los campos');
      return;
    }

    try {
      Dio dio = Dio();
      final response = await dio.post(
        apiUrl,
        data: requestBody,
      );
      if (response.statusCode == 200) {
        _showToast(response.data['message']);
        eventController.clear();
        getData();
        // ignore: use_build_context_synchronously
        Provider.of<NavigationProvider>(context, listen: false).selectedIndex =
            2;
      } else {
        print(
            'Error en la solicitud. Código de estado: ${response.statusCode}');
        print('Mensaje de error: ${response.data}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
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

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
