import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/gifts_provider.dart';
import '../controllers/user_provider.dart';
import '../domain/event_model.dart';
import '../domain/gift_model.dart';

class InvitedEventDetails extends StatefulWidget {
  final EventItem event;

  const InvitedEventDetails({super.key, required this.event});

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

    print(widget.event.id);
    try {
      final response = await dio.get(
        'https://zasok.com/api/giftList/${widget.event.eventId}',
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
                    return const Center(
                        child: Text('No hay regalos disponibles'));
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('No hay eventos disponibles'));
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

                        // Verificar si dedicatory no es nulo antes de mostrar el ListTile
                        if (gift.dedicatory == null) {
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
                                  child: Image.network(
                                    'https://zasok.com/storage/images/${gift.userId}/${gift.photo}',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    gift.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(context: context, 
                                    builder: (context) => GiftConfirmationDialog(
                                      giftId: gift.id,
                                      onConfirm: (){
                                        obtenerRegalos();
                                        }
          
                                      ));
                                  },
                                  icon: const Icon(Icons.check, color: Colors.green),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Si dedicatory es nulo, retornar un contenedor vacío o null
                          return Container();
                        }
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


class GiftConfirmationDialog extends StatefulWidget {
  final int giftId;
  final VoidCallback onConfirm;

  const GiftConfirmationDialog({super.key, required this.giftId,required this.onConfirm});

  @override
  State<GiftConfirmationDialog> createState() => _GiftConfirmationDialogState();
}

class _GiftConfirmationDialogState extends State<GiftConfirmationDialog> {
  final TextEditingController dedicatoriaController = TextEditingController();

  Future<void> _sendDedicatory() async {

    final Map<String, dynamic> data = {
      'gift_id': widget.giftId,
      'dedicatory': dedicatoriaController.text.isNotEmpty ? dedicatoriaController.text : 'Sin dedicatoria',
    };

    print(data);

    try {
      final Dio dio = Dio();
      final response = await dio.post(
        'https://zasok.com/api/addDedicatory',
        data: data,
      );

      if (response.statusCode == 200) {
        widget.onConfirm.call();
        print('Dedicatory added successfully');
        _showToast('Dedicatoria agregada con éxito');
        // Puedes realizar acciones adicionales después de una respuesta exitosa
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        // Puedes manejar el error de acuerdo a tus necesidades
      }
    } catch (e) {
      print('Error: $e');
      // Puedes manejar el error de acuerdo a tus necesidades
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Quieres otorgar este regalo al anfitrión?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: dedicatoriaController,
            decoration: const InputDecoration(
              hintText: 'Dedicatoria (opcional)',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dedicatoria es opcional',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            dedicatoriaController.clear();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            _sendDedicatory();
            Navigator.of(context).pop();
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

   void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
