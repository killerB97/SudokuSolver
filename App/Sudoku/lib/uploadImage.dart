import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
  print(r.statusCode);
  print(await r.stream.transform(utf8.decoder).join());
}


