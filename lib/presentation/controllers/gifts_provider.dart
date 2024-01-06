import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/gift_model.dart';

class GiftProvider with ChangeNotifier {
  List<GiftItem> _giftList = [];
  final _giftListController = StreamController<List<GiftItem>>.broadcast();

  // Getter para acceder al stream
  Stream<List<GiftItem>> get giftListStream => _giftListController.stream;

  List<GiftItem> get giftList => _giftList;

  void updateGiftList(List<GiftItem> gifts) {
    _giftList = gifts;
    _giftListController.add(gifts);
    notifyListeners();
  }

  void addGift(GiftItem gift) {
    _giftList.add(gift);
    _giftListController.add(_giftList);
    notifyListeners();
  }

  void deleteGift(int giftId) {
    _giftList.removeWhere((gift) => gift.id == giftId);
    _giftListController.add(_giftList);
    notifyListeners();
  }

  void dispose() {
    _giftListController.close();
    super.dispose();
  }
}
