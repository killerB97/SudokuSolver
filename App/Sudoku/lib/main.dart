import 'package:Sudoku/MyCustomClipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipe_button/swipe_button.dart';
import 'dart:async';
import 'dart:io';
import 'Bouncy.dart';

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
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
          height: 250,
          color: Colors.orangeAccent,
          child:  Center(
            child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
            child: Column(
            children: <Widget> [
           Text("Sudo",
            style: TextStyle(
              fontFamily: 'Mark',
              fontSize: 60.0,
              color: Colors.grey[800]
            ),
          ),
           Text("Magic",
            style: TextStyle(
              fontFamily: 'Monoton',
              fontSize: 40.0,
              color: Colors.white
            ),
          ),
            ],),
          ),),),
          ),
        ],
      ),
      bottomNavigationBar: 
      CurvedNavigationBar(
      backgroundColor: Colors.white,
      color: Colors.orangeAccent,
      height: 60,
      index: 1,
      animationDuration: Duration(milliseconds: 200),
      items: <Widget>[
        Icon(Icons.add_box, size: 35, color: Colors.grey[800]),
        Icon(Icons.camera_enhance, size: 35,color: Colors.grey[800]),
        Icon(Icons.help, size: 35,color: Colors.grey[800]),
      ],
      onTap: (index) {
        if (index==0){
          Timer(Duration(milliseconds: 350), (){
            Navigator.push(
              context, Bouncy(widget: Upload())    
        );
        });
        }
        if (index==1){
          Timer(Duration(milliseconds: 350), (){
            Navigator.push(
              context,
              Bouncy(widget: Camera())
              );
            
        });}
        if (index==2){
          print('tutorial');
        }
        //Handle button tap
      },
    ),
    );
    
  }
}

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  
  Future <File> _selectedFile;


  Widget getImageWidget(newFile) {
    if (newFile != null) {
      return Container(
  height: 350,
  width: 350,
  decoration: BoxDecoration(
    color: const Color(0xff7c94b6),
    image: DecorationImage(
      image: 
      FileImage(
        newFile,
      ),
    fit:BoxFit.cover
    ),
    border: Border.all(
      color: Colors.grey[900],
      width: 5.0,
    ),
  ),
);
    } else {
      return Container(
  height: 350,
  width: 350,
  decoration: BoxDecoration(
    color: const Color(0xff7c94b6),
    image: DecorationImage(
      image: AssetImage('images/placeholder.png')
    ),
    border: Border.all(
      color: Colors.white,
      width: 5.0,
    ),
  ),
);
    }
  }
  Future <File> imgDisp(ImageSource source) async {
      final picker = ImagePicker();
      final image = await picker.getImage(source: source);

      if(image != null){
            File cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(
                ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.orangeAccent,
              toolbarTitle: "RPS Cropper",
              statusBarColor: Colors.grey[800],
              backgroundColor: Colors.white,
            )
        );

        return cropped;

  }
        else{
          return null;
        }
  }

  @override
  void initState() {
    super.initState();
    _selectedFile = imgDisp(ImageSource.gallery);
  }
  
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: _selectedFile,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.waiting:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.active:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.done: {
              var newFile = snapshot.data;
              return   SafeArea(
        child: Scaffold(
        backgroundColor: Colors.orangeAccent,
        body: Column(
          children: <Widget>[
            //ClipRRect(
            //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0),bottomRight: Radius.circular(15.0)),
            Container(
            height: 80,
            decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[800],
                blurRadius: 10.0,
                offset: Offset(0.0, 0.5)
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0),bottomRight: Radius.circular(15.0))),
            //color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  color: Colors.white,
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Icon(Icons.arrow_back,size:30.0,color:Colors.grey[800])
                  ),
                SizedBox(width:75),
                Text( "Upload",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Raleway',
                    color: Colors.grey[800]
                  ),
                )

              ],
              )
            ),
            //),
          SizedBox(height:60),
          getImageWidget(newFile),
          SizedBox(height:70),
          RaisedButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white)
            ),
            onPressed: () {},
            child: Text(
            "Solve",
            style: TextStyle(
              fontSize: 40.0,
              fontFamily: 'Monoton',
              color: Colors.grey[900],
              //fontFamily: 'Monoton'
            ),
          )
          ),
          ],
        )
        )
    );
              }

            }
          },

    );
  }
}

class Camera extends StatefulWidget {
  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  
  Future <File> _selectedFile;
  

  Widget getImageWidget(newFile) {
    if (newFile != null) {
      return Container(
  height: 350,
  width: 350,
  decoration: BoxDecoration(
    color: const Color(0xff7c94b6),
    image: DecorationImage(
      image: 
      FileImage(
        newFile,
      ),
    fit:BoxFit.cover
    ),
    border: Border.all(
      color: Colors.grey[900],
      width: 5.0,
    ),
  ),
);
    } else {
      return Container(
  height: 350,
  width: 350,
  decoration: BoxDecoration(
    color: const Color(0xff7c94b6),
    image: DecorationImage(
      image: AssetImage('images/placeholder.png')
    ),
    border: Border.all(
      color: Colors.white,
      width: 5.0,
    ),
  ),
);
    }
  }
  Future <File> imgDisp(ImageSource source) async {
      final picker = ImagePicker();
      final image = await picker.getImage(source: source);

      if(image != null){
            File cropped = await ImageCropper.cropImage(
            sourcePath: image.path,
            aspectRatio: CropAspectRatio(
                ratioX: 1, ratioY: 1),
            compressQuality: 100,
            maxWidth: 700,
            maxHeight: 700,
            compressFormat: ImageCompressFormat.jpg,
            androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.orangeAccent,
              toolbarTitle: "RPS Cropper",
              statusBarColor: Colors.grey[800],
              backgroundColor: Colors.white,
            )
        );
        if(cropped !=null) {
        return cropped;}
        else {
          Navigator.pop(context);
        }}

      else{
          Navigator.pop(context);
        }
  }

  @override
  void initState() {
    super.initState();
    _selectedFile = imgDisp(ImageSource.camera);
  }
  
  Widget build(BuildContext context) {
    return FutureBuilder(
          future: _selectedFile,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.waiting:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.active:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Colors.orangeAccent),));
              case ConnectionState.done: {
              var newFile = snapshot.data;
              return   SafeArea(
        child: Scaffold(
        backgroundColor: Colors.orangeAccent,
        body: Column(
          children: <Widget>[
            Container(
            height: 80,
            decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[800],
                blurRadius: 10.0,
                offset: Offset(0.0, 0.5)
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0),bottomRight: Radius.circular(15.0))),
            //color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  color: Colors.white,
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Icon(Icons.arrow_back,size:30.0,color:Colors.grey[800])
                  ),
                SizedBox(width:75),
                Text( "Camera",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Raleway',
                    color: Colors.grey[800]
                  ),
                )

              ],
              )
            ),
          SizedBox(height:60),
          getImageWidget(newFile),
          SizedBox(height:70),
          RaisedButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white)
            ),
            onPressed: () {},
            child: Text(
            "Solve",
            style: TextStyle(
              fontSize: 40.0,
              fontFamily: 'Monoton',
              color: Colors.grey[900],
              //fontFamily: 'Monoton'
            ),
          )
          ),

          ],
        )
        )
    );
              }

            }
          },

    );
  }
}