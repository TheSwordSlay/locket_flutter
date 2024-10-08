abstract class DatabaseSystem<T> {
  Stream<T>? getShopItemsStream();

  Stream<T>? getCheckoutItemsStream(String email);

  Stream<T>? getOrdersDataStream();

  T getShopItemData(String namaItem);

  T getCheckoutItemsData(String email);

  Future finishOrder(String emailTarget);

  Future<void> decreaseShopItem(String namaItem, int amount);

  Future<void> increaseShopItem(String namaItem, int amount);

  Future<void> updateCheckoutData(String email, newData);

  Future<void> updateOrderData(String email, newData);
}