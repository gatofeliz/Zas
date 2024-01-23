import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/events_provider.dart';
import '../../controllers/gifts_provider.dart';
import '../../controllers/user_provider.dart';
import '../../domain/event_model.dart';
import '../../domain/gift_model.dart';
import 'navbar_widget.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventItem event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final GiftProvider giftProvider = GiftProvider();
  TextEditingController nameController = TextEditingController();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    obtenerRegalos();
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = XFile(pickedImage.path);
      });
    }
  }

  Future<void> obtenerRegalos() async {
    final dio = Dio();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await dio.get(
        'https://zasok.com/api/giftList/${widget.event.id}',
        options: Options(
          headers: {'Authorization': 'Bearer ${userProvider.userToken}'},
        ),
      );

      if (response.statusCode == 200) {
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

  Future<void> _addGift(String userToken, String name, int eventID, int? userId,
      File photo) async {
    final dio = Dio();
    final headers = {'Authorization': 'Bearer $userToken'};

    try {
      final formData = FormData.fromMap({
        'name': name,
        'event_id': eventID,
        'user_id': userId,
        'photo': await MultipartFile.fromFile(photo.path),
      });

      final response = await dio.post(
        'https://zasok.com/api/storeGift',
        data: formData,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('Regalo almacenado con éxito');
      } else {
        print(
            'Error al almacenar el regalo. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición: $e');
    }
  }

  Future<void> _deleteEvent(int eventId, String userToken) async {
    final dio = Dio();
    final headers = {'Authorization': 'Bearer $userToken'};
    try {
      final response = await dio.delete(
        'https://zasok.com/api/deleteEvent/$eventId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('Evento eliminado con éxito');
      } else {
        print(
            'Error al eliminar el evento. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición: $e');
    }
  }

  Future<void> _deleteGift(int giftId, String userToken) async {
    final dio = Dio();
    final headers = {'Authorization': 'Bearer $userToken'};

    try {
      final response = await dio.delete(
        'https://zasok.com/api/deleteGift/$giftId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('Regalo eliminado con éxito');
        obtenerRegalos(); // Actualiza la lista de regalos después de eliminar uno
      } else {
        print(
            'Error al eliminar el regalo. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición: $e');
    }
  }

  Future<void> _publicarEvento(int idEvent) async {
    final dio = Dio();

    try {
      final response = await dio
          .put('https://zasok.com/api/published', data: {'id': idEvent});

      if (response.statusCode == 200) {
        print('Evento publicado con éxito');
      } else {
        print(
            'Error al publicar el evento. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la petición: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
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
            Text(
              'Nombre del Evento: ${widget.event.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha del evento: ${widget.event.timedate}',
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.event.published != "false")
              Text(
                'Codigo de evento: ${widget.event.code}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'Añadir Regalo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: _pickedImage != null
                          ? Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.camera_alt,
                                size: 40.0,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Agregar regalo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_pickedImage != null) {
                  _addGift(
                    userProvider.userToken,
                    nameController.text,
                    widget.event.id,
                    userProvider.userId,
                    File(_pickedImage!.path),
                  );
                  obtenerRegalos();
                } else {
                  // Manejar el caso donde no se ha seleccionado una imagen
                  print('Debes seleccionar una imagen para el regalo.');
                }
              },
              child: const Text('Agregar Regalo',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            const Text(
              'Lista de Regalos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<List<GiftItem>>(
                stream: giftProvider.giftListStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                                  child: Image.network(
                                      'https://zasok.com/storage/images/${userProvider.userId}/${gift.photo}'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    gift.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteGift(
                                        gift.id, userProvider.userToken);
                                    giftProvider.deleteGift(gift.id);
                                  },
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
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.event.published == "false"
                          ? () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      PaypalCheckoutView(
                                        sandboxMode: false,
                                        clientId:
                                            "AZKmKo4mCCTQT2GWMNGqKaIcXqffYMTqclvAaZ0UpZCNNP2YB_b-jfWGiGw9nEVwNXEDk-74xAY4P0CY",
                                        secretKey:
                                            "ED1Roj6I6yKGjcuVZO4CVu7KZPr1PGlT4Ux70fpGasGNbEeAdelmozv5W-7gvnf66ev0AMPEZvbWjt2v",
                                        onSuccess: (result) async {
                                          Navigator.pop(context);
                                          _publicarEvento(widget.event.id);
                                          _showEventCodeDialog(
                                              widget.event.code);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PrincipalScreen(),
                                            ),
                                          );
                                        },
                                        note: 'Compra tus eventos',
                                        onError: (error) {
                                          print(error);
                                          Navigator.pop(context);
                                          _showToast(
                                              'Error en la transacción: $error');
                                        },
                                        onCancel: () {
                                          Navigator.pop(context);
                                          _showToast('Transacción cancelada');
                                        },
                                        transactions: const [
                                          {
                                            "amount": {
                                              "total": '1',
                                              "currency": "MXN",
                                              "details": {
                                                "subtotal": '1',
                                                "shipping": '0',
                                                "shipping_discount": 0
                                              }
                                            },
                                            "description": "Creacion de Evento",
                                            "item_list": {
                                              "items": [
                                                {
                                                  "name": "Evento",
                                                  "quantity": 1,
                                                  "price": '1',
                                                  "currency": "MXN"
                                                },
                                              ],
                                            }
                                          }
                                        ],
                                      )));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Publicar',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirmar eliminación'),
                              content: const Text(
                                  '¿Seguro que quieres eliminar este evento?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Sí'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirmDelete == true) {
                          await _deleteEvent(
                              widget.event.id, userProvider.userToken);
                          eventProvider.deleteEvent(widget.event.id);
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrincipalScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Eliminar Evento',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventCodeDialog(String eventCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Código del Evento'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Este es tu código de evento!\nCompartelo para invitar:\n '),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  eventCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy),
                onPressed: () {
                  _copyToClipboard(eventCode);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('Código copiado al portapapeles');
  }
}
