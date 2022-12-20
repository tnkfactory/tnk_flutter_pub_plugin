import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';

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
    super.initState();
  }

  Future<void> showInterstitial() async {
    String tnkResult;
    try {
      // 전면광고를 출력합니다.
      tnkResult = await _tnkFlutterPubPlugin.showInterstitial("TEST_INTERSTITIAL_V") ?? "onFail";
    } on PlatformException catch(e){
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
              onPressed: (){ showInterstitial(); },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('show interstitial'),
            ),
          ],
          )
        ),
      ),
    );
  }
}
