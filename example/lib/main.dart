import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub_example/tnk_flutter_rwd_analytics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tnkResult = 'Unknown';

  // Tnk pub plugin
  final _tnkFlutterPubPlugin = TnkFlutterPub();

  @override
  void initState() {
    MethodChannel channel = const MethodChannel('tnk_flutter_pub');
    channel.setMethodCallHandler(tnkInvokedMethods);
    super.initState();
  }

  Future<dynamic> tnkInvokedMethods(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "TnkAdListener":
        String result = TnkRewardVideoListener.onEvent(methodCall.arguments, "pubtest");
        if (result == TnkRewardVideoListener.PASS) {
          // 해당 placement id의 이벤트가 아님
          print(result);
        } else if (result == TnkRewardVideoListener.SUCCESS) {
          // 보상 지급
          print(result);
        } else {
          // 보상 지급 실패
          print(result);
        }
        break;
    }
  }

  Future<void> showInterstitial() async {
    String tnkResult;
    try {
      // 전면광고를 출력합니다.
      tnkResult = await _tnkFlutterPubPlugin.showInterstitial("pubtest") ?? "onFail";
    } on PlatformException catch (e) {
      tnkResult = e.message ?? "onFail";
    }
    // 성공시 : onShow
    // 실패시 : e.message에 담긴 에러메세지 (ex : publicher Id or Placement Id is not registered.)

    if (!mounted) return;

    setState(() {
      _tnkResult = tnkResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('tnk pub plugin test app'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('result \n\n$_tnkResult\n'),
            OutlinedButton(
              onPressed: () {
                showInterstitial();
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('show interstitial'),
            ),
          ],
        )),
      ),
    );
  }
}
