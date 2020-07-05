import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'PayResult.dart';

typedef void PayResultCallback(String recipeData);
typedef void PayInfoCallback(String desc, int price);

class Flutterpay {
  static PayResultCallback _payResultCallback;
  static PayInfoCallback _payInfoCallback;
  static const MethodChannel _channel = const MethodChannel('flutterpay');

  static void init() {
    _channel.setMethodCallHandler((call) {
      var method = call?.method;
      print("method = ${method}");
      switch (method) {
        case 'returnPayResult':
          var recipeData = call.arguments['recipeData'];
          print("recipeData  callback = ${Flutterpay._payResultCallback}");
          if (Flutterpay._payResultCallback != null) {
            Flutterpay._payResultCallback(recipeData);
          }
          break;
        case 'returnPayInfo':
          var price = call.arguments['price'];
          var desc = call.arguments['desc'];
          if (Flutterpay._payInfoCallback != null) {
            Flutterpay._payInfoCallback(desc, price);
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
    await _channel.invokeMethod('setPayInfo', payInfo);
  }

  static Future<void> getPayInfo(PayInfoCallback payInfoCallback) async {
    _payInfoCallback = payInfoCallback;
    await _channel.invokeMethod('getPayInfo');
  }

  static Future<void> pay(PayResultCallback payResultCallback) async {
    Flutterpay._payResultCallback = payResultCallback;
    await _channel.invokeMethod('pay');
  }

//  'https://pay.ifreedomer.com/pay/verifyApplePay'
  static Future<PayResult> verifyPay(
      String url, String openId, String productId, String recipeData) async {
    var dio = new Dio(BaseOptions(headers: {
      'Content-Type': 'application/json;charset=utf-8',
    }));

    dio.httpClientAdapter = DefaultHttpClientAdapter();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    var response = await dio.post(url,
        data: {
          'openId': openId,
          'productId': productId,
          'recipeData': recipeData
        },
        options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }));
    print(
        "response = ${response.statusCode}  data = ${response.data.toString()}");
    var payResult = PayResult();
    payResult.state = response.data['data'];
    payResult.message = response.data['message'];
    return payResult;
  }
}
