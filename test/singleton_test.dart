import 'package:flutter_test/flutter_test.dart';
import 'TestClass.dart';

void main() {
  test('Testing singleton feature', () {
    var class1 = TestClass();
    var class2 = TestClass();
    expect(identical(class1, class2), true);
  });
}
