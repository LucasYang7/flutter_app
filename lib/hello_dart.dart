dynamic a; // dynamic申明的变量可以在后面修改版变量类型
Object b; // Object是所有类的根类，所以其支持后期修改变量类型
// final表示一个变量只能被设置一次,final变量命名一般是驼峰式
final finalString = "final string";
// const表示编译时的常量
const constString = "const string";

void main() {
  a = "";
  b = "123";
  var test = "Hello Dart!"; // var申明的变量无法再修改类型
//  test = 1;    // test已经被赋值为String类型了，无法再将其赋值为int
  print(test);
  printLengths();

  TestFunction testFunc = new TestFunction();
  testFunc.testFunction(testFunc.isNumberInit);
  testFunc.say("one", "two");
  testFunc.say("1", "2", "3");
  testFunc.sayParams("1", third: "3", four: "4");

  TestFuture testFuture = new TestFuture();
  testFuture.futureDelay();
  testFuture.futureWait();
}

void printLengths() {
  print("a.length is ${a.length}");
  print("b.hashCode is ${b.hashCode}");
//  print(b.lenght);  // Object对象只能调用Object类中的方法
}

int testInt;

class TestFunction {
  // 和kotlin类似，对于只包含一个表达式的函数，可以简化成 => 这种写法
  bool isNumberInit(int atomicNumber) => atomicNumber != null;

  testFunction(callBack cb) {
    print("testInt init is ${cb(testInt)}");
  }

  // [] 代表可选参数，这样可以减少函数重载的个数
  say(String first, String second, [String third]) {
    print("first is $first,second is $second.");
    if (third != null) {
      print("third is $third.");
    } else {
      print("third is null.");
    }
  }

  // {} 代表可选的命名参数，需要放到函数参数列表最后面，不能与可选参数[]一起混用
  sayParams(String first, {String second, String third, String four}) {
    print(
        "sayParams first is $first,second is $second,third is $third,four is $four.");
  }
}

// 函数也是对象类型
typedef callBack = bool Function(int a);

class TestFuture {
  // 测试Future Delay
  void futureDelay() {
    // 测试异步任务Future
    print("before Future.delayed now is ${new DateTime.now()}");
    Future.delayed(new Duration(seconds: 2), () {
      // 在这里模拟耗时操作computation
      return "delayed this is delayed 2s,now is ${new DateTime.now()}";
    }).then((data) {
      // 相当于RxJava中的onNext回调
      print("then $data,now is ${new DateTime.now()}");
    }).catchError((e) {
      // 相当于RxJava中的onError回调
      print(e);
    }).whenComplete(() {
      // 相当于RxJava中的onComplete回调
      print("whenComplete,now is ${new DateTime.now()}");
    });
  }

  void futureWait() {
    print("before Future.wait now is ${new DateTime.now()}");
    // Future wait类似于RxJava中的zip操作符
    Future.wait([
      Future.delayed(new Duration(seconds: 2), () {
        // 延时2秒执行
        return "first now is ${new DateTime.now()},";
      }),
      Future.delayed(new Duration(seconds: 4), () {
        // 延时4秒执行
        return "second now is ${new DateTime.now()}";
      })
    ]).then((results) {
      print("then " + results[0] + results[1] + ",now is ${new DateTime.now()}");
    }).whenComplete(() {
      print("when Complete() now is ${new DateTime.now()}");
    });
  }
}
