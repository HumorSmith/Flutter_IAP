import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'PayResult.dart';

typedef void PayResultCallback(String signInfo);

class Flutterpay {
  static PayResultCallback _payResultCallback;
  static const MethodChannel _channel = const MethodChannel('flutterpay');

  static void init() {
    _channel.setMethodCallHandler((call) {
      var method = call?.method;
      print("method = ${method}");
      switch (method) {
        case 'returnPayResult':
          var recipeData = call.arguments['recipeData'];
          print("recipeData  callback = ${Flutterpay._payResultCallback}");
          if(Flutterpay._payResultCallback!=null){
            Flutterpay._payResultCallback(recipeData);
          }
          break;
      }
    });
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> get canPay async {
    final bool canPay = await _channel.invokeMethod('canPay', '');
    return canPay;
  }

  static Future<void> setParam(Map<String, dynamic> params) async {
    await _channel.invokeMethod('setParam');
  }

  static Future<void> setPayInfo(Map<String, dynamic> payInfo) async {
    await _channel.invokeMethod(
        'setPayInfo', {'productId': 'com.ifreedomer.timenote.month'});
  }

  static Future<void> pay(PayResultCallback payResultCallback) async {
    Flutterpay._payResultCallback = payResultCallback;
    await _channel.invokeMethod('pay');
  }

  static Future<PayResult> verifyPay(
      String openId, String productId, String recipeData) async {
    var dio = new Dio();

    var response =await dio.post('https://pay.ifreedomer.com/pay/verifyApplePay', queryParameters: {
      'openId': openId,
      'productId': 4,
      'recipeData': recipeData
    },options: Options(
        followRedirects: false,
        validateStatus: (status) { return status < 500; }
    ));
    print("response = ${response.statusCode}  data = ${response.data.toString()}");
    return new PayResult();

  }
}
