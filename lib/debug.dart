// import 'dart:typed_data';
// import 'dart:ui' as UI;
// import 'not use/controller.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:convert';

// class LocalImageSource implements ImageSource {
//   static final LocalImageSource instance = LocalImageSource._();

//   final Map<String, UI.Image> images;
//   final Map<String, Uint8List> byteImages;

//   LocalImageSource._() : images = {}, byteImages = {};

//   Future<void> load({required callback}) async {
//     List<Future<void>> list = [];
//     String jsonString = await rootBundle.loadString("asset/imageData.json");
//     dynamic jsonObj = jsonDecode(jsonString);

//     for(MapEntry<String, dynamic> entry in jsonObj["images"].entries) {
//       list.add(_load(entry.key, entry.value));
//     }

//     await Future.wait<void>(list).then((_) => callback());
//   }

//   Future<void> _load(String name, String fileName) async {
//     ByteData data = await rootBundle.load("asset/images/$fileName");

//     Uint8List list = Uint8List.view(data.buffer);
//     byteImages[name] = list;

//     Completer<void> completer = Completer();
//     UI.decodeImageFromList(list, (UI.Image image) {
//       images[name] = image;
//       completer.complete();
//     });

//     return completer.future;
//   }

//   Uint8List getByteImage(String name) {

//     // TODO: implement getByteImage
//     throw UnimplementedError();
//   }

//   UI.Image getImage(String name) {
//     // TODO: implement getImage
//     throw UnimplementedError();
//   }

//   UI.Size getSize(String name) {
//     // TODO: implement getSize
//     throw UnimplementedError();
//   }

// }