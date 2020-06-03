import 'package:flutter/material.dart';


class MyCustomClipper extends CustomClipper <Path>{
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    final Path path = Path();
    path.lineTo(0.0, size.height);
    //path.lineTo(25,size.height);
    var endpoint = Offset(size.width,size.height-75);
    var control = Offset(size.width*.5,size.height-25);
    path.quadraticBezierTo(control.dx, control.dy, endpoint.dx, endpoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
    // TODO: implement shouldReclip
  

}