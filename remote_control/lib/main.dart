import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'joy_stick.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Future<Socket> socket=
  Socket socket = null;
  String host = "192.168.4.1";
  String host1=null;

  void _incrementCounter() {
    setState(() {});
  }

  void _message(String msg) {
    host1=host;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(msg),
            content: TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.home),
                labelText: host,
                helperText: "服务地址",
                helperStyle: TextStyle(
                  color: Colors.green, //绿色
                  fontSize: 20, //字体变大
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (val) {
                print("点击了键盘上的动作按钮，当前输入框的值为：${val}");
                host1 = val;
              },
              onChanged: (val) {
                print(val);
                host1 = val;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop('ok');
                },
              ),
              FlatButton(
                child: Text('确认'),
                onPressed: () async {
                  //host="192.168.4.1";
                  //await initSocket();
                  Navigator.of(context).pop(host);
                  host=host1;

                },
              ),
            ],
          );
        });
  }
   initSocket() async{
    if (this.socket!=null)
      return;
    await Socket.connect(host, 6000,
        timeout: Duration(milliseconds: 2000)).then((Socket s)  {
      this.socket = s;
      //mStream=mSocket.asBroadcastStream();      //多次订阅的流 如果直接用socket.listen只能订阅一次
      this.socket.listen((event) async {

          print('useragreement listen :$event');
          this.socket.add(event);
          await this.socket.flush();
      });
    }).catchError((e) {
      print('connectException:$e');
      //initSocket();
      _message("链接错误,请确认地址");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text(
            //  'xxx.xxx.xxx.xxx',
            //  style: Theme.of(context).textTheme.headline4,
            //),
            //FlatButton(
            //  child: Text("取消"),
            //  onPressed: () => Navigator.of(context).pop(),
            //),
            JoyStick(onInit: (Offset delta)=>initSocket(),
                onChange: (Offset delta) async {
              var dx = delta.dx.toStringAsFixed(3);
              var dy = delta.dy.toStringAsFixed(3);
              final cmd = "AT+SPEED:R$dx,L$dy\n";
              print(cmd);
              //await socket?.drain();

              socket?.write(cmd);
              //socket.add(cmd);
              await socket?.flush(); //发送
              //socket?.transform(FixedLengthTransform(5));
              // socket.transform(utf8.decoder).listen(print);
            }, onDestory: (Offset delta) async {
              //await socket.flush();

              //
              //await socket.drain();
              await socket?.destroy();
              socket = null;
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _message("修改"),
        tooltip: '设置地址',
        child: Icon(Icons.settings),
        // child:Text("修改地址"),
      ),
    );
  }
}
