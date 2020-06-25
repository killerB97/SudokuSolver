import 'package:Sudoku/MyCustomClipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:bubble/bubble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:Sudoku/ClipShadowPath.dart';
import 'package:Sudoku/uploadImage.dart';
import 'package:Sudoku/circleReveal.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
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
    print(size);
    return SafeArea(
      child: Container(
      decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/sky3.png"), fit: BoxFit.cover)),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            ClipShadowPath(
            shadow: Shadow(
            blurRadius: 0
            ),
            clipper: MyCustomClipper(),
            child: Container(
            height: size.height*0.30,
            color: Color.fromRGBO(242, 243, 244,1 ),
            child:  Center(
              child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, size.height*0.3*0.08, 0.0, 0.0),
              child: Column(
              children: <Widget> [
             Text("Sudo",
              style: TextStyle(
                fontFamily: 'Sweet',
                fontSize: size.height*0.092,
                color: Color.fromRGBO(62, 48, 100,1) 
              ),
            ),
             Text("Magic",
              style: TextStyle(
                fontFamily: 'Monoton',
                fontSize: size.height*0.046,
                color: Color.fromRGBO(159, 135, 167,1)
              ),
            ),
              ],),
            ),),),
            ),
          ],
        ),
        bottomNavigationBar: 
        CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Color.fromRGBO(242, 243, 244,1),
        height: 60,
        index: 1,
        animationDuration: Duration(milliseconds: 200),
        items: <Widget>[
          Icon(Icons.add_box, size: 35, color: Color.fromRGBO(62, 48, 100,1)),
          Icon(Icons.camera_enhance, size: 35,color: Color.fromRGBO(62, 48, 100,1)),
          Icon(Icons.help, size: 35,color: Color.fromRGBO(62, 48, 100,1)),
        ],
        onTap: (index) {
          if (index==0){
            Timer(Duration(milliseconds: 350), (){
              Navigator.push(
                context,
                RevealRoute(
                  page: Upload('Upload',ImageSource.gallery),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.topLeft,),
                );}  
          );
          }

          if (index==1){
            Timer(Duration(milliseconds: 350), (){
              Navigator.push(
                context,
                RevealRoute(
                  page: Upload('Camera',ImageSource.camera),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.topLeft,),
                ); 
          });}
          if (index==2){
            print('tutorial');
          }
          //Handle button tap
        },
    ),
    ),
      ));
    
  }
}

class Upload extends StatefulWidget {
  final String head;
  final ImageSource src;

  Upload(this.head,this.src);

  @override
  _UploadState createState() => _UploadState(head,src);
}

class _UploadState extends State<Upload> {
  String head;
  ImageSource src;

  _UploadState(this.head,this.src);
  Future <File> _selectedFile;

  Widget getImageWidget(newFile, imgSize) {
    Size size = MediaQuery.of(context).size;
    if (newFile != null) {
      return Container(
  height: imgSize,
  width: imgSize,
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
      color: Color.fromRGBO(159, 135, 167,1),
      width: 2.0,
    ),
  ),
);
    } else {
      return Container(
  height: imgSize,
  width: imgSize,
  decoration: BoxDecoration(
    color: const Color(0xff7c94b6),
    image: DecorationImage(
      image: AssetImage('images/placeholder.png')
    ),
    border: Border.all(
      color: Color.fromRGBO(62, 48, 100,1),
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
              statusBarColor: Color.fromRGBO(23, 32, 42 , 1),
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
    var cont_size = size.height/8 + size.height*0.26 - size.height/8  + size.width-50;
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
    _selectedFile = imgDisp(src);
  }
  
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var imgSize = size.height*size.width*0.0011<size.width-70? size.height*size.width*0.0011: size.width-70;
    print(size);
    return FutureBuilder(
          future: _selectedFile,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Color.fromRGBO(62, 48, 100,1))));
              case ConnectionState.waiting:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Color.fromRGBO(62, 48, 100,1))));
              case ConnectionState.active:
              return Center(child:CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color> (Color.fromRGBO(62, 48, 100,1))));
              case ConnectionState.done: {
              var newFile = snapshot.data;
              uploadImageToServer(newFile);
              return   SafeArea(
              child: Container(
                  decoration: BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage("images/sky3.jpg"), fit: BoxFit.cover)),
          child: Scaffold(
          backgroundColor: Colors.transparent,
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
                  Text( head,
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
            getImageWidget(newFile, imgSize),
            SizedBox(height:buttonHeight(size)),
            FlatButton(
                color: Color.fromRGBO(19, 8, 49,1) ,
                shape: StadiumBorder(
                //borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Color.fromRGBO(159, 135, 167,1)),
                
              ),
              onPressed: () {
                Navigator.push(
                context,
                  RevealRoute(
                  page: Loading(size),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.bottomCenter,),
                );
                
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Text(
                "Solve",
                style: TextStyle(
                  fontSize: 40.0,
                  fontFamily: 'Potra',
                  color: Colors.white),
                  //gradient: LinearGradient(
                  //colors: [Color.fromRGBO(35, 31, 54,1), Color.fromRGBO(84, 66, 116,1), Color.fromRGBO(168, 148, 175,1)])
                  //fontFamily: 'Monoton'
            ),
              )
            ),
            ],
          )
          ),
        )
    );
              }

            }
          },

    );
  }
}

class Loading extends StatefulWidget {
  Size size;

  Loading(this.size);
  @override
  _LoadingState createState() => _LoadingState(size);
}

class _LoadingState extends State<Loading> {
    Size size;
    var myFile;
    _LoadingState(this.size);

    void initState() {
    super.initState();
    startTime();
  }


  startTime() async {
    myFile = await networkImageToByte();
    //myFile = null;
    var duration = new Duration(seconds: 5);
    return new Timer(duration, route);
  }

  route() {
              Navigator.push(
              context,
                RevealRoute(
                page: Answer(myFile),
                maxRadius: size.height*1.46,
                centerAlignment: Alignment.centerRight,),
              );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      backgroundColor: Color.fromRGBO(19, 8, 49,1), 
      image: Image.asset('images/loader2.gif'),
      loaderColor: Color.fromRGBO(19, 8, 49,1),
      photoSize: 150,
      //navigateAfterSeconds: Answer(), 
      //navigateAfterSeconds: Answer(),
      loadingText: Text(
        'Solving',
        style: TextStyle(fontFamily: 'Monoton', fontSize: 40.0, color: Colors.white)

      ),
    );
  }
}

class Answer extends StatefulWidget {
  var myFile;
  Answer(this.myFile);
  @override
  _AnswerState createState() => _AnswerState(myFile);
}

class _AnswerState extends State<Answer> {
  @override

  var finalImage;
  var myFile;

  _AnswerState(this.myFile);


  @override
  void initState() {
    super.initState();
    finalImage = getImageFromServer();
    _requestPermission();
    //finalImage = NetworkImage("http://192.168.0.132:5000/answer?dummy=${ValueKey(new Random().nextInt(1000))}");
  }

  getImgHeight(Size size,double imgSize) {
    var total = size.height*0.675;
    var img = (size.height*0.25)/2 + imgSize;
    var gap = (total-img)*0.05;
    return img+gap;
  }

  getCardHeight(Size size,double imgSize) {
    var total = size.height*0.675;
    var img = (size.height*0.25)/2 + imgSize;
    var gap = (total-img)*0.05;
   var cardht = img+gap+size.height*0.035+size.height*0.008*2+30;
   return cardht;
  }
  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var imgSize = size.height*size.width*0.0011<size.width-70? size.height*size.width*0.0011: size.width-70;
    return SafeArea(
    child: Container(
    decoration: BoxDecoration(
         image: DecorationImage(
         image: AssetImage("images/sky3.jpg"), fit: BoxFit.cover)),     
    child: Scaffold(
      backgroundColor: Colors.transparent,
        body: Column(
        children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, size.height*0.017, 0.0, 0.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        color: Colors.transparent,
                        onPressed: (){
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 2);
                        }, 
                        child: Icon(Icons.arrow_back,size:30.0,color:Colors.white)
                        ),
                        SizedBox(width: size.width - 180,),
                        FlatButton(
                        color: Colors.transparent,
                        onPressed: (){
                Navigator.push(
                    context,
                    RevealRoute(
                      page: Sudoku(),
                      maxRadius: size.height*1.17,
                      centerAlignment: Alignment.topRight,),
                    );
                        }, 
                        child: Icon(Icons.home,size:32.0,color:Colors.white)
                        ),                  
                        ]),
                  ),
                  SizedBox(height: size.height*0.875 - getCardHeight(size, imgSize)),
                  Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Container(
                      width: size.width,
                      height: getCardHeight(size, imgSize),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45.0),
                          topRight: Radius.circular(45.0)
                        ),
                        ),
                      ),
                       Positioned(
                           right: size.width/2 - size.height*0.069,
                           top: -40,
                      child: CircularProfileAvatar(
                      '',
                      child: Image.asset('images/robot_alt.png'),
                      borderColor: Color.fromRGBO(62, 48, 100,1),
                      borderWidth: 0,
                      elevation: 2,
                      backgroundColor: Colors.blue,
                      radius: size.height*0.069
                    ),
                       ),
                    Positioned(
                              top: (size.height*0.25)/2,
                              left: (size.width-imgSize)/2,
                              child: Center(
                              child: Container(
                              height: imgSize,
                              width: imgSize,
                              decoration: BoxDecoration(
                              border: Border.all(
                              color: Color.fromRGBO(62, 48, 100,1), //                   <--- border color
                              width: 2.0,
                        ),
                              ),
                              child: FadeInImage(
                              width: imgSize, 
                              height: imgSize,
                              placeholder: AssetImage('images/loader3.gif'),
                              image: finalImage,
                              fit: BoxFit.cover,)
                              
                        )
                        ),
                    ),
                      Positioned(
                        top: getImgHeight(size,imgSize),
                        right: (size.width-imgSize)/4.5,
                        child: RawMaterialButton(
                          onPressed: () async{
                            await Share.file('Sudo Answer', 'sudoans.png', myFile, 'image/png');
                          },
                          elevation: 3.0,
                          fillColor: Colors.white,
                          child: Icon(
                            Icons.share,
                            size: size.height*0.035,
                            color: Colors.deepOrangeAccent,
                          ),
                          padding: EdgeInsets.all(size.height*0.008),
                          shape: CircleBorder(
                          side: BorderSide(color: Color.fromRGBO(62, 48, 100,1))
                          ),
                        ),
                      ),
                      Positioned(
                        top: getImgHeight(size,imgSize),
                        left: (size.width-imgSize)/4.5,
                        child: RawMaterialButton(
                          onPressed: () async{
                              final result = await ImageGallerySaver.saveImage(myFile);  
                              _toastInfo(result.toString()); 
                          },
                          elevation: 3.0,
                          fillColor: Colors.white,
                          child: Icon(
                            Icons.file_download,
                            size: size.height*0.035,
                            color: Colors.deepOrangeAccent,
                          ),
                          padding: EdgeInsets.all(size.height*0.008),
                          shape: CircleBorder(
                          side: BorderSide(color: Color.fromRGBO(62, 48, 100,1))
                          ),
                        ),
                      ),                    
                    ],
                  )
        ]
      ,),
    )
    ));
  }
}





        //     Expanded(
        //   child: Bubble(
        //   elevation: 6.0,
        //   margin: BubbleEdges.only(top: 10),
        //   nip: BubbleNip.leftTop,
        //   alignment: Alignment.topLeft,
        //   child: Text('Hello Human! I am the AI that powers this app. I have solved the puzzle to the best of my abilities. Don\'t hesitate to compliment me :D',
        //   style: TextStyle(fontFamily: 'Pokemon', fontSize: 10, height: 1.5),
        //   ),
        // )),


