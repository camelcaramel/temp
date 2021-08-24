import 'package:stage4viscuit/classes/view_model/storage.dart';

import 'need_engine.dart';
import 'package:test/test.dart';
import '../component/component.dart';
import '../view_model/storage.dart';

void main() {
  final Need need = Need();
  need.fillFromJson(json1);
  final SOMap current = need.current;
  final InstructionStorageSnapshot snapshot = need.snapshot;

  print(current);

  final Stopwatch stopwatch = Stopwatch();
  stopwatch.start();
  for(int i = 0; i < 10; i++) need.generate(current, snapshot);
  stopwatch.stop();

  print("걸린 시간: ${stopwatch.elapsed.inMilliseconds}ms");

}





String json1 = """{
  "type": "viscuit",
  "version": "6.0",
  "machine": "13368527414183249249",
  "stage": [
    {
      "type": "vispict",
      "name": "P2897",
      "x": 342.4000244140625,
      "y": 268.16,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P2897",
      "x": 328.3199951171875,
      "y": 144.63993164062504,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P1621",
      "x": 432.000048828125,
      "y": 216.31996093750004,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P2897",
      "x": 191.99996337890624,
      "y": 239.99999023437505,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P3583",
      "x": 411.519970703125,
      "y": 71.68001953125004,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P3583",
      "x": 363.5199951171875,
      "y": 354.56000000000006,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P3583",
      "x": 135.03994140625,
      "y": 145.92007080078128,
      "rotation": 0
    },
    {
      "type": "vispict",
      "name": "P1621",
      "x": 231.0400146484375,
      "y": 149.1200463867188,
      "rotation": 0
    }
  ],
  "rules": [
    {
      "type": "rule",
      "x": 287.360009765625,
      "y": 170.24000244140626,
      "head": [
        {
          "type": "vispict",
          "name": "P1621",
          "x": 60,
          "y": 61.21141148158476,
          "rotation": 0
        }
      ],
      "body": [
        {
          "type": "vispict",
          "name": "P2897",
          "x": 84.18284737723206,
          "y": 82.9714358956473,
          "rotation": 0
        }
      ]
    },
    {
      "type": "vispict",
      "name": "P1621",
      "x": 366.0375082957986,
      "y": 360.6400500488282,
      "rotation": 0
    }
  ],
  "picts": [
    {
      "type": "picture",
      "name": "P1621",
      "base64": "eJwNxUERgEAMA8AwEMoDBVhARIXxOY3nAwW0oX3s7I3nen0AELB4P9v5b1q1i0kxjs/SkkGxAEwzEKk="
    },
    {
      "type": "picture",
      "name": "P2897",
      "base64": "eJwdy8ERhUAIA9Dwkb38CmzBJmzNPqzNJrzIosCi8ybJKQv24HUDkH7Mt3S5mjYVFWObTHr1w07lF/RB4k0GHBH1PAH612IAaXMhRA=="
    },
    {
      "type": "picture",
      "name": "P3583",
      "base64": "eJwljW0KwjAQBWezqQm16CkET6FX87j+UBShtR/JpillGR6PB7NX8vNyfwBW+YCca94yOaXR/jaUnoFZFskUYT+lIZRIlCMtrQQXnVevTpxHZZ+VYE0KcxgP3+51ene/ttdJJ7dQ7ZhZKdkSaati9X/1b6zJPjQc"
    }
  ],
  "bg": [
    12189600,
    12189600
  ],
  "option": {
    "type": "view",
    "c2": 12189600,
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
    "c1": 12189600,
    "hasrotatebtn": true,
    "width": 512,
    "height": 384,
    "haspencil": true
  }
}""";