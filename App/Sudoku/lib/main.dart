import 'package:Sudoku/MyCustomClipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Sudoku(),
    debugShowCheckedModeBanner: false,
  ));
}

class Sudoku extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Column(
        children: <Widget>[
          ClipPath(
          child: Container(
        child: new Text("Flutter Cheatsheet",
            style: TextStyle(
              fontSize: 50.0
              
            ),
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
            height: 250,
            color: Colors.grey[900],
          ),
          clipper: MyCustomClipper(),
          ),
        ],
      ),
      bottomNavigationBar: 
      CurvedNavigationBar(
      backgroundColor: Colors.deepOrangeAccent,
      color: Colors.grey[900],
      items: <Widget>[
        Icon(Icons.add, size: 35, color: Colors.amberAccent),
        Icon(Icons.camera_enhance, size: 35,color: Colors.amberAccent),
        Icon(Icons.list, size: 35,color: Colors.amberAccent),
      ],
      onTap: (index) {
        //Handle button tap
      },
    ),
    );
    
  }
}