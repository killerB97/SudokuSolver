import 'package:Sudoku/MyCustomClipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:bubble/bubble.dart';
import 'package:Sudoku/uploadImage.dart';
import 'dart:async';
import 'dart:math';
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
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
          height: size.height*0.34,
          color: Colors.orangeAccent,
          child:  Center(
            child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, size.height*0.045, 0.0, 0.0),
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
    ));
    
  }
}

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  
  Future <File> _selectedFile;


  Widget getImageWidget(newFile) {
    Size size = MediaQuery.of(context).size;
    if (newFile != null) {
      return Container(
  height: size.width - 50,
  width: size.width - 50,
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

  double buttonHeight(Size size){
    var bottom_size = size.height - size.height*0.16;
    var cont_size = size.height/8 + size.height*0.25 - size.height/8  + size.width-50;
    var button = bottom_size - cont_size;
    return button;
  }

    double imgHeight(Size size){
    var cont_size = size.height*0.23 - size.height/8;
    return cont_size;
  }

  @override
  void initState() {
    super.initState();
    _selectedFile = imgDisp(ImageSource.gallery);
  }
  
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(size);
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
            height: (size.height)/8,
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
                SizedBox(width: size.width/5.5),
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
          SizedBox(height: imgHeight(size)),
          getImageWidget(newFile),
          SizedBox(height:buttonHeight(size)),
          RaisedButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white)
            ),
            onPressed: () {
              uploadImageToServer(newFile);
              Navigator.push(
              context,
              Bouncy(widget: Loading())
              );
              
            },
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
    Size size = MediaQuery.of(context).size;
    if (newFile != null) {
      return Container(
  height: size.width - 60,
  width: size.width - 60,
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

    double buttonHeight(Size size){
    var bottom_size = size.height - size.height*0.16;
    var cont_size = size.height/8 + size.height*0.25 - size.height/8  + size.width-50;
    var button = bottom_size - cont_size;
    return button;
  }

    double imgHeight(Size size){
    var cont_size = size.height*0.23 - size.height/8;
    return cont_size;
  }

  @override
  void initState() {
    super.initState();
    _selectedFile = imgDisp(ImageSource.camera);
  }
  
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
            height: size.height/8,
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
                SizedBox(width:size.width/5.5),
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
          SizedBox(height: imgHeight(size)),
          getImageWidget(newFile),
          SizedBox(height: buttonHeight(size)),
          RaisedButton(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.white)
            ),
            onPressed: () async {
              await uploadImageToServer(newFile);
              Navigator.push(
              context,
              Bouncy(widget: Answer())
              );
              },
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

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      backgroundColor: Color.fromRGBO(1, 11, 19,1), 
      image: Image.asset('images/loading.gif'),
      loaderColor: Color.fromRGBO(1, 11, 19,1),
      photoSize: 150,
      navigateAfterSeconds: Answer(), 
      loadingText: Text(
        'Solving',
        style: TextStyle(fontFamily: 'Monoton', fontSize: 40.0, color: Color.fromRGBO(35, 221, 236,1))

      ),
    );
  }
}

class Answer extends StatefulWidget {
  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  @override

  NetworkImage finalImage;

  double imgHeight(Size size){
    var cont_size = size.height*0.20 - size.height/8;
    return cont_size;
  }

  Widget getImageWidget(newFile) {
    Size size = MediaQuery.of(context).size;
    if (newFile != null) {
      return Container(
  height: size.width - 50,
  width: size.width - 50,
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

  @override
  void initState() {
    super.initState();
    finalImage = NetworkImage("http://192.168.0.132:5000/answer?dummy=${ValueKey(new Random().nextInt(1000))}");
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.green[300],
      body:Column(
        children: <Widget>[
            Container(
            height: size.height/8,
            decoration: BoxDecoration(
          color: Colors.green[300],
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15.0),bottomRight: Radius.circular(15.0))),
            //color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  color: Colors.green[300],
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Icon(Icons.arrow_back,size:30.0,color:Colors.white)
                  ),
                  SizedBox(width: size.width - 180,),
                  FlatButton(
                  color: Colors.green[300],
                  onPressed: (){
                  Navigator.push(
                  context,
                  Bouncy(widget: Sudoku())
              );
                  }, 
                  child: Icon(Icons.home,size:32.0,color:Colors.white)
                  ),                  
                  ])),

      Padding(
      padding: EdgeInsets.fromLTRB(size.width*0.07, size.width*0.025, size.width*0.07, 0.0),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget> [
      CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('images/robot_alt.png'),
        ),
      SizedBox(width: size.width*0.05),
      Expanded(
        child: Bubble(
        elevation: 6.0,
        margin: BubbleEdges.only(top: 10),
        nip: BubbleNip.leftTop,
        alignment: Alignment.topLeft,
        child: Text('Hello Human! I am the AI that powers this app. I have solved the puzzle to the best of my abilities. Don\'t hesitate to compliment me :D',
        style: TextStyle(fontFamily: 'Pokemon', fontSize: 10, height: 1.5),
        ),
      )),
           
      ])),
        SizedBox(height: imgHeight(size)), 
        Center(
        child: Container(
        height: size.width - 50,
        width: size.width-50,
        decoration: BoxDecoration(
      image: DecorationImage(image: finalImage,
      ),
      border: Border.all(
      color: Colors.grey[900],
      width: 5.0,
    ),
    ),
    )
    ),]
      )
    ));
  }
}

class Incorrect extends StatefulWidget {
  @override
  _IncorrectState createState() => _IncorrectState();
}

class _IncorrectState extends State<Incorrect> {
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      
    );
  }
  // color_code loading_gif rgb(1, 11, 19)
}