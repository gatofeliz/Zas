import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/gifts_provider.dart';
import '../controllers/user_provider.dart';
import '../domain/event_model.dart';
import '../domain/gift_model.dart';

class InvitedEventDetails extends StatefulWidget {
  final EventItem event;

  const InvitedEventDetails({Key? key, required this.event}) : super(key: key);

  @override
  State<InvitedEventDetails> createState() => _InvitedEventDetailsState();
}

class _InvitedEventDetailsState extends State<InvitedEventDetails> {
  final GiftProvider giftProvider = GiftProvider();

  @override
  void initState() {
    super.initState();
    obtenerRegalos(); 
  }

  Future<void> obtenerRegalos() async {
    final dio = Dio();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await dio.get(
        'https://zas.onta.com.mx/api/giftList/${widget.event.id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${userProvider.userToken}'},
        ),
      );

      if (response.statusCode == 200) {
        print('esto es el result del fetch ${response.data}');
        final List<dynamic> giftsData = response.data['gifts'];

        giftProvider.updateGiftList(
          giftsData.map((gift) => GiftItem.fromJson(gift)).toList(),
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
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  return Scaffold(
    appBar: AppBar(
      title: const Text('Detalles del Evento'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regalos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<GiftItem>>(
              stream: giftProvider.giftListStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('No hay regalos disponibles'));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('No hay eventos disponibles'));
                } else {
                  final List<GiftItem> gifts = snapshot.data ?? [];
                  if (gifts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aún no hay regalos.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: gifts.length,
                      itemBuilder: (context, index) {
                        final GiftItem gift = gifts[index];
                        return ListTile(
                          title: Row(
                            children: [
                              Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Image.network('https://zas.onta.com.mx/storage/images/${userProvider.userId}/${gift.photo}'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  gift.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
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
    ),
  );
}
}
