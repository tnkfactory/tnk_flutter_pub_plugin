import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub.dart';
import 'package:tnk_flutter_pub/tnk_flutter_pub_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _tnk_result = 'Unknown';
  final _tnkFlutterPubPlugin = TnkFlutterPub();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> showInterstitial() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await TnkFlutterPubPlatform.instance.showInterstitial("TEST_INTERSTITIAL_") ?? "onFail";
    } on PlatformException catch(e){
      platformVersion = e.message ?? "onFail";
      // platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _tnk_result = platformVersion;
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
            Text('result \n\n$_tnk_result\n'),
            OutlinedButton(
              onPressed: (){ showInterstitial(); },
              child: Text('show interstitial'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
            ),
          ],
          )
        ),
      ),
    );
  }
}
