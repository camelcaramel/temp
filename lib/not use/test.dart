import '../classes/test/debug.dart';

import 'instruction.dart';
import 'package:flutter/material.dart';


String jsonString = """
{
  "type": "viscuit",
  "version": "6.0",
  "machine": "13368527414183249249",
  "stage": [],
  "rules": [
    {
      "type": "rule",
      "x": 325.12001953125,
      "y": 136.3199951171875,
      "head": [
        {
          "type": "vispict",
          "name": "P1760",
          "x": 60,
          "y": 66.33143101283476,
          "rotation": 0
        }
      ],
      "body": [
        {
          "type": "vispict",
          "name": "P2918",
          "x": 75.22283761160706,
          "y": 68.8914065987723,
          "rotation": 0
        }
      ]
    },
    {
      "type": "rule",
      "x": 284.1599609375,
      "y": 299.5199951171875,
      "head": [
        {
          "type": "vispict",
          "name": "P2918",
          "x": 60,
          "y": 70.49153843470975,
          "rotation": 0
        }
      ],
      "body": [
        {
          "type": "vispict",
          "name": "P2918",
          "x": 81.62303292410706,
          "y": 71.13149448939731,
          "rotation": 0
        }
      ]
    }
  ],
  "picts": [
    {
      "type": "picture",
      "name": "P1760",
      "base64": "eJwNxcENgDAMA0Aj4hKB2IMtWK2zsBtfJsBO+zjdhfc57g7A0wcsM5zhJpoKNa/af4q1VTprAGUpEaI="
    },
    {
      "type": "picture",
      "name": "P2918",
      "base64": "eJwNxTERADAIBMFLRxEdaSICa+hEADKY/2JnP+92FrA2cMIjOkgD5A=="
    }
  ],
  "bg": [
    16763872,
    16763872
  ],
  "option": {
    "type": "view",
    "c2": 16763872,
    "speed": 400,
    "dynamic": true,
    "grid": 0,
    "ivloop": 0,
    "hidetools": {
      "drawer": true,
      "share": true,
      "numpos": true,
      "rotate": false,
      "pencil": false,
      "tone": false,
      "touch": false,
      "setting": false
    },
    "ihloop": 0,
    "c1": 16763872,
    "hasrotatebtn": true,
    "width": 512,
    "height": 384,
    "haspencil": true
  }
}
""";


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> list = [CircularProgressIndicator()];
  int _counter = 0;

  void initState() {
    LocalImageSource.instance.load(callback: start); // setState를 호출해도 한번만 실행됨

    super.initState();
  }

  void start() {

    var o = InstructionSource.instance = InstructionSource();
    o.create(jsonString);

    for(Instruction instruction in o.instructions) {
      print(instruction.head);
      print(instruction.body);
    }

    setState(() {
      list.length = 0;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
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
          children: list,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}



