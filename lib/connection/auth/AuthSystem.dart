abstract class AuthSystem<T> {
  Stream<T>? getAuthState();

  Future<T> signIn(String email, String password);

  Future signUp(String email, String password);

  Future<T> signOut();

  T getCurrentUserInstance();

  Future<void> updateUserData(String field, newData);

  Stream<T>? getCurrentUserSnapShot();
}