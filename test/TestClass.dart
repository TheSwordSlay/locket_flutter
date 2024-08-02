class TestClass {
  static final TestClass _TestClass = TestClass._internal();
  
  factory TestClass() {
    return _TestClass;
  }

  TestClass._internal();
}