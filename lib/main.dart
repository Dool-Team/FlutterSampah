import 'package:trashcare/core.dart';
// ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
// navigatorKey;: Get.navigatorKey,;
import 'package:flutter/material.dart';
import 'package:trashcare/splash.dart';


void main(){
  runApp (MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) :super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}