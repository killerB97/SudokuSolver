import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';


Map<String, String> headers = {};



void updateCookie(http.StreamedResponse response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

uploadImageToServer(File imageFile)async
{
  http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('http://192.168.0.132:5000/sudomagic'));

  request.files.add(
    await http.MultipartFile.fromPath(
      'images',
      imageFile.path,
      contentType: MediaType('application', 'jpeg'),
    ),
  );

  http.StreamedResponse r = await request.send();
  updateCookie(r);
  print(r.statusCode);
  print(await r.stream.transform(utf8.decoder).join());
}

NetworkImage getImageFromServer()
{ 
  return NetworkImage("http://192.168.0.132:5000/answer?dummy=${ValueKey(new Random().nextInt(1000))}", headers: headers);
}

Future<Uint8List> networkImageToByte() async {
  http.Response response = await http.get(
    "http://192.168.0.132:5000/answer?dummy=${ValueKey(new Random().nextInt(1000))}", 
    headers: headers,
); 
return response.bodyBytes;
}


