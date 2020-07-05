import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'resources/app_config.dart';
import 'dart:math';
import 'dart:convert';


Map<String, String> headers = {};
AppConfig url = AppConfig();




void updateCookie(http.StreamedResponse response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

Future <List> uploadImageToServer(File imageFile)async
{ var sudoku;
  String resp;
  http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url.postUrl));

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
  Map<String, dynamic> responseJson = json.decode(await r.stream.bytesToString());
  print('received ping');
  sudoku = responseJson['response'];
  if (sudoku is List){
    print(sudoku);
    return sudoku;
  }
  else{
  //
  return [];}
}

NetworkImage getImageFromServer(bool error, List sudoku)
{ 
  if (error == true){
  headers['sudoku'] = sudoku.toString();
  return NetworkImage("${url.getresUrl}?dummy=${ValueKey(new Random().nextInt(1000))}", headers: headers);    
  }
  else{
  return NetworkImage("${url.getUrl}?dummy=${ValueKey(new Random().nextInt(1000))}", headers: headers);
  }
}

Future<Uint8List> networkImageToByte() async {
  http.Response response = await http.get(
    "${url.getUrl}?dummy=${ValueKey(new Random().nextInt(1000))}", 
    headers: headers,
); 
return response.bodyBytes;
}

Future<Uint8List> uploadResolved(List sudoku) async{
  headers['sudoku'] = sudoku.toString();
  http.Response response = await http.get(
    "${url.getresUrl}?dummy=${ValueKey(new Random().nextInt(1000))}", 
    headers: headers,
); 
  return response.bodyBytes;
}



