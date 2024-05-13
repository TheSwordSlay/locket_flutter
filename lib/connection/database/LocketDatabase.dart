import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locket_flutter/connection/database/DatabaseSystem.dart';

class LocketDatabase implements DatabaseSystem {

  final checkoutCollection = FirebaseFirestore.instance.collection("Checkout");
  final shopCollection = FirebaseFirestore.instance.collection("ShopItems");

  static final LocketDatabase _LocketDatabase = LocketDatabase._internal();
  
  factory LocketDatabase() {
    return _LocketDatabase;
  }
  
  LocketDatabase._internal();

  @override
  getCheckoutItemsData(String email) {
    return checkoutCollection.doc(email).get();
  }

  @override
  getShopItemData(String namaItem) {
    return shopCollection.doc(namaItem).get();
  }

  @override
  Stream? getShopItemsStream() {
    return FirebaseFirestore.instance
                  .collection("ShopItems")
                  .snapshots();
  }

  @override
  Future<void> updateCheckoutData(String email, newData) {
    return checkoutCollection.doc(email).set(
      newData
    );
  }

  @override
  Future<void> updateShopItemData(String namaItem, String field, newData) {
    return shopCollection.doc(namaItem).update({field: newData});
  }
  
  @override
  Future<void> updateOrderData(String email, newData) {
    return FirebaseFirestore.instance
      .collection("Orders")
      .doc(email)
      .set(newData);
  }
  
  @override
  Stream? getCheckoutItemsStream(String email) {
    return FirebaseFirestore.instance.collection("Checkout").doc(email).snapshots();
  }
  
  @override
  Future finishOrder(String emailTarget) async {
    FirebaseFirestore.instance
      .collection("Users")
      .doc(emailTarget)
      .update({
        'isOrdering': false
      });
    FirebaseFirestore.instance
      .collection("Checkout")
      .doc(emailTarget)
      .update({
        'items': [],
        'total': 0
      });
    FirebaseFirestore.instance
      .collection("Orders")
      .doc(emailTarget)
      .delete();
  }
  
  @override
  Stream? getOrdersDataStream() {
    return FirebaseFirestore.instance.collection("Orders").snapshots();
  }
  
}