import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterpay/flutterpay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    Flutterpay.init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Flutterpay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    Flutterpay.setPayInfo({'productId':'com.ifreedomer.timenote.forever'});
    Flutterpay.getPayInfo((desc, price) {
      print("getPayInfo desc = ${desc}  price = ${price}");
    });


    setState(() {



      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:Column(
            children: [
              RaisedButton(
                onPressed: (){
                  Flutterpay.setPayInfo({'productId':'com.ifreedomer.timenote.month'});
                },
                child: Text("设置支付参数"),
              ),
              RaisedButton(
                onPressed: (){
                  Flutterpay.pay((recipeData){
                    print("pay result = ${recipeData}");
                    Flutterpay.verifyPay('haha', "productId", recipeData);
                  });

                },
                child: Text("支付"),
              ),
              Text('Running on: $_platformVersion\n'),
            ],
          )

        ),
      ),
    );
  }
}
