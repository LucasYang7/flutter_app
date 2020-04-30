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

  // 回调炼狱
  callBackHell(testFuture);

  // 使用Future then语法去掉回调炼狱
  solveCallbackHell(testFuture);

  // 使用async和await关键字消除回调炼狱
  asyncTask(testFuture);

  testStream();
}

void solveCallbackHell(TestFuture testFuture) {
  print("before solveCallbackHell() now is ${new DateTime.now()}");
  testFuture.login("lukas", "123456").then((id) {
    return testFuture.getUserInfo(id);
  }).then((userInfo) {
    return testFuture.saveUserInfo(userInfo);
  }).then((saveUserInfo) {
    print("solveCallbackHell $saveUserInfo");
  });
}

void callBackHell(TestFuture testFuture) {
  print("before callBackHell() now is ${new DateTime.now()}");
  testFuture.login("lukas", "123456").then((id) {
    testFuture.getUserInfo(id).then((userInfo) {
      testFuture.saveUserInfo(userInfo).then((saveInfo) {
        print("callBackHell $saveInfo");
      });
    });
  });
}

// async 用来表示函数是异步的，定义的函数会返回一个Future对象，可以使用then方法添加回调函数。
asyncTask(TestFuture testFuture) async {
  print("before asyncTask() now is ${new DateTime.now()}");
  // await后面是一个Future，表示等待该异步任务完成，异步完成后才能走后面的逻辑,await必须出现在async函数内部。
  String id = await testFuture.login("lukas", "123456");
  print("asyncTask() execute login, now is ${new DateTime.now()}");
  String userInfo = await testFuture.getUserInfo(id);
  print("asyncTask() execute getUserInfo, now is ${new DateTime.now()}");
  String saveInfo = await testFuture.saveUserInfo(userInfo);
  print("asyncTask() execute saveUserInfo, now is ${new DateTime.now()}");
  print("asyncTask() $saveInfo");
}

void testStream() {
  // Stream 也是用于接收异步事件数据，和Future不同的是，它可以接收多个异步操作的结果(成功或者失败)
  // 这个有点类似于RxJava中的Obserable flatMap，Stream常用于会多次读取数据的异步任务场景，例如内容下载，文件读写。
  Stream.fromFutures([
    // 延迟1s
    Future.delayed(new Duration(seconds: 1), () {
      return "hello 1";
    }),
    Future.delayed(new Duration(seconds: 2), () {
      throw AssertionError("Assert Error");
    }),
    Future.delayed(new Duration(seconds: 3), () {
      return "world 3";
    })
  ]).listen((data) {
    print("$data,now is ${new DateTime.now()}");
  }, onError: (handleError) {
    print("$handleError,now is ${new DateTime.now()}");
  }, onDone: () {
    print("onDone,now is ${new DateTime.now()}");
  });
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
      print(
          "then " + results[0] + results[1] + ",now is ${new DateTime.now()}");
    }).whenComplete(() {
      print("when Complete() now is ${new DateTime.now()}");
    });
  }

  // 模拟登陆耗时操作
  Future<String> login(String userName, String password) {
    return Future.delayed(new Duration(seconds: 2), () {
      if (userName == "lukas" && password == "123456") {
        return "True,now is ${new DateTime.now()}";
      } else {
        return "False,now is ${new DateTime.now()}";
      }
    });
  }

  // 模拟获取信息操作
  Future<String> getUserInfo(String id) {
    return Future.delayed(new Duration(seconds: 2), () {
      if (id.startsWith("True")) {
        return "lukas,china,29,now is ${new DateTime.now()}";
      } else {
        return "null information,now is ${new DateTime.now()}";
      }
    });
  }

  // 模拟保存信息的操作
  Future<String> saveUserInfo(String userInfo) {
    return Future.delayed(new Duration(seconds: 2), () {
      return "Save infomation success! now is ${new DateTime.now()}";
    });
  }
}
