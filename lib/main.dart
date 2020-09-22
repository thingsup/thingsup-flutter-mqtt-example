import 'package:flutter/material.dart';
import 'MQTTExample.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget
{
  @override
  MyAppState createState()=> MyAppState();
}

class MyAppState extends State<MyApp>{

  @override

  Widget build(BuildContext context) {

    return
      MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:MQTTExample(),
      );
  }
}