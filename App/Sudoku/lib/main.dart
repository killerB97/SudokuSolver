import 'package:Sudoku/MyCustomClipper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:Sudoku/ClipShadowPath.dart';
import 'package:Sudoku/uploadImage.dart';
import 'package:Sudoku/circleReveal.dart';
import 'resources/app_config.dart';
import 'package:speech_bubble/speech_bubble.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'dart:async';
import 'dart:io';

//

Future <void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = getPref(prefs);
    runApp(MaterialApp(
    home:_seen ? SudoMagic():Onboarding(),
    debugShowCheckedModeBanner: false,
  ));
}

bool getPref(SharedPreferences pref){
  if (pref.containsKey('seen')){
    return true;
  }
  else{
    pref.setBool('seen', true);
    return false;
  }
}

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {


  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget pageIndicator(int currentPage, int page){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: currentPage==page? 13.0 : 8.0,
      width:  currentPage==page? 13.0 : 8.0,
      decoration: BoxDecoration(
        color: currentPage==page? Colors.white : Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
        )
    );
  }
  
  Widget Screens(Size size,String imgPath,Color bgColor, String header, String body, int page, int screens,LiquidController control, int skipJump, IconData icon){
        return SafeArea(
        child: Scaffold(
        backgroundColor: bgColor,
        body: Container(
        height: size.height,
        width: size.width,
        child: Stack(
          children: <Widget>[

              page!=screens-1? Positioned(
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      control.jumpToPage(
                        page: control.currentPage + skipJump
                        );
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Quicksand'
                      )
                  ),
                    ),
                  ),
              ):Container()
              ,
              Positioned(
                    top: 0.15 * size.height,
                    left: size.width/2 - size.width*size.height*0.0004,
                    child: CircularProfileAvatar(
                    '',
                    child: Image.asset(imgPath),
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    radius: size.width*size.height*0.0004
                  ),
              ),
              Positioned(
                  top: 0.55*size.height,
                  left: 30,
                  child: Text(
                  header,
                  style: TextStyle(
                    fontSize: size.height*0.034,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Raleway',
                    color: Colors.white
                  ),
                ),
              ),
            
            Positioned(
                top: 0.6*size.height,
                left: 30,
                right: 30,
                child: Container(
                  child: Text(
                  body,
                  style: TextStyle(
                    fontSize: size.height*0.022,
                    fontFamily: 'QuickLight',
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  )
              ),
                ),
            ),
            page!=screens-1?Positioned(
                top: 0.8*size.height,
                left:size.width/2 - 18,
                child: Container(
                height: 45.0,
                width: 45.0,
                child: Icon(icon,size:30.0,color:Colors.grey[800]),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ):
            Positioned(
                top: 0.8*size.height,
                left:size.width/2 - (size.width/2 - 50),
                child: Container(
                height: size.height*0.08,
                width: size.width-100,
                child: FlatButton(
                  onPressed: (){
                Navigator.push(
                  context,
                  RevealRoute(
                    page: SudoMagic(),
                    maxRadius: size.height*1.17,
                    centerAlignment: Alignment.bottomCenter,),
                ); 
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600
                    )
                  )
                ),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(	63, 61, 86,1),
                  borderRadius: BorderRadius.circular(10.0)
                ),
              ),

            ),
            Positioned(
                top: size.height - 60,
                left: size.width/2-32,
                child: Row(
                children: <Widget>[
                  for(int i=0; i<screens;i++) pageIndicator(i, page)
                ],),
            ),
          
          ],)
  ),
      ),
    );
}
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    int noOfScreens = 4;
    var control = LiquidController();
    AppConfig obj = AppConfig();

    return LiquidSwipe(
      pages: [
        Screens(size,'images/upload.png',Color.fromRGBO(	63, 61, 86,1),'Upload Image',obj.OnboardingText1,0, noOfScreens,control,3, Icons.add_box),
        Screens(size,'images/camera.png',Color.fromRGBO(249, 168, 38,1), 'Click Picture',obj.OnboardingText2,1,noOfScreens,control,2, Icons.camera_enhance),
        Screens(size,'images/fix.png',Color.fromRGBO(140, 122, 230,1), 'Edit and Solve',obj.OnboardingText3,2,noOfScreens,control,1, Icons.touch_app),
        Screens(size,'images/Download.png',Color.fromRGBO(255, 99, 102,1), 'Download and Share',obj.OnboardingText4,3,noOfScreens,control,0, Icons.share)
      ],
      liquidController: control,
      enableLoop: false,
      );
  }
}


class SudoMagic extends StatelessWidget {
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
            Timer(Duration(milliseconds: 350), (){
              Navigator.push(
                context,
                RevealRoute(
                  page: Onboarding(),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.bottomRight,),
                );}  
          );
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
    print(imgSize);
    if (newFile != null) {
      return Container(
  height: imgSize,
  width: imgSize,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(imgSize*0.087),
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
    } 
  }
  Future <File> imgDisp(ImageSource source) async {
      final picker = ImagePicker();
      final image = await picker.getImage(source: source);
      Size size = MediaQuery.of(context).size;

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
          if (source==ImageSource.gallery)
          {Navigator.pop(context);}
          else {
                Navigator.push(
                context,
                RevealRoute(
                  page: Upload('Camera',ImageSource.camera),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.topLeft,),
                ); 
          }
        }}

        else{
          if (source==ImageSource.gallery)
          {Navigator.pop(context);}
          else {
                Navigator.push(
                context,
                RevealRoute(
                  page: SudoMagic(),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.bottomRight,),
                );             
          }
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

  Future <File> imgProcess(ImageSource src) async {
    var img = await imgDisp(src);
    return img;
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
              if (newFile!=null)
              {
              return   SafeArea(
              child: Container(
                  decoration: BoxDecoration(
                  image: DecorationImage(
                  image: AssetImage("images/sky3.png"), fit: BoxFit.cover)),
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
                side: BorderSide(color: Colors.white),
                
              ),
              onPressed: () {
                Navigator.push(
                context,
                  RevealRoute(
                  page: Loading(size,newFile),
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
    else {
      return SafeArea(
          child: Container(
          height: size.height,
          width: size.width,
          color: Color.fromRGBO(62, 48, 100,1)
        ),
      );
    }
              }
            }
          },

    );
  }
}

class Loading extends StatefulWidget {
  Size size;
  File newFile;
  Loading(this.size,this.newFile);
  @override
  _LoadingState createState() => _LoadingState(size,newFile);
}

class _LoadingState extends State<Loading> {
    Size size;
    File newFile;
    var myFile;
    List resp;

    _LoadingState(this.size,this.newFile);

    void initState() {
    super.initState();
    startTime();
  }


  startTime() async {
    resp = await uploadImageToServer(newFile);
    if (resp.length==0){
    myFile = await networkImageToByte();
    //myFile = null;
    var duration = new Duration(seconds: 1);
    return new Timer(duration, route);
    }
    else{
      myFile = false;
      var duration = new Duration(seconds: 1);
      return new Timer(duration, route);
    }

  }

  route() {
              Navigator.push(
              context,
                RevealRoute(
                page: Answer(myFile,resp,false),
                maxRadius: size.height*1.46,
                centerAlignment: Alignment.centerRight,),
              );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 10,
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

class Reloading extends StatefulWidget {
  Size size;
  List sudoku;
  Reloading(this.size,this.sudoku);
  @override
  _ReloadingState createState() => _ReloadingState(size,sudoku);
}

class _ReloadingState extends State<Reloading> {
    Size size;
    List sudoku;
    var myFile;


    _ReloadingState(this.size,this.sudoku);

    void initState() {
    super.initState();
    startTime();
  }


  startTime() async {
    myFile = await uploadResolved(sudoku);
    //myFile = null;
    var duration = new Duration(seconds: 1);
    return new Timer(duration, route);

  }

  route() {
              Navigator.push(
              context,
                RevealRoute(
                page: Answer(myFile,sudoku,true),
                maxRadius: size.height*1.46,
                centerAlignment: Alignment.centerRight,),
              );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 10,
      backgroundColor: Color.fromRGBO(8, 2, 4,1), 
      image: Image.asset('images/resolver.gif'),
      loaderColor: Color.fromRGBO(8, 2, 4,1),
      photoSize: 150,
      //navigateAfterSeconds: Answer(), 
      //navigateAfterSeconds: Answer(),
      loadingText: Text(
        'Resolve',
        style: TextStyle(fontFamily: 'Monoton', fontSize: 40.0, color: Color.fromRGBO(237, 68, 26,1))

      ),
    );
  }
}

class Answer extends StatefulWidget {
  var myFile;
  var resp;
  bool error;

  Answer(this.myFile,this.resp,this.error);
  @override
  _AnswerState createState() => _AnswerState(myFile,resp,error);
}

class _AnswerState extends State<Answer> {
  @override

  var finalImage;
  var myFile;
  var resp; 
  bool error;

  bool flag = false ;

  _AnswerState(this.myFile,this.resp, this.error);


  @override
  void initState() {
    super.initState();
    if (myFile is bool){
      flag = true;
    }
    else{
    finalImage = getImageFromServer(error,resp);
    _requestPermission();
    }
    //finalImage = NetworkImage("http://192.168.0.132:5000/answer?dummy=${ValueKey(new Random().nextInt(1000))}");
  }

  List <dynamic> getBorders(int row, int col){
      List topLeft = [false,false];
      if (row%3==0){
          topLeft[0] = true;
      }
      if (col%3==0){
          topLeft[1] = true;
      }
      return topLeft;
  }

  Widget sudokuCell(int row,int col, double imgSize,int value,List resp){
    final controller = TextEditingController(text:value==0?'':'$value');
    var topLeft = getBorders(row, col);
    return Container(
      height: imgSize/9,
      width: imgSize/9,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: topLeft[0]? BorderSide(width: 2.0, color: Color.fromRGBO(	63, 61, 86,1)): BorderSide(width: 0.0, color: Color.fromRGBO(	63, 61, 86,1)),
          left: topLeft[1]? BorderSide(width: 2.0, color: Color.fromRGBO(	63, 61, 86,1)): BorderSide(width: 0.0, color: Color.fromRGBO(	63, 61, 86,1))
        )
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(color:Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
        onChanged: (text){
          controller.text = text;
          if(text==''){
            text = '0';
          }
          resp[row][col] = int.parse(text);
        },
      ),
    );
  }

  List <Widget> getRow(int rowNumber, double imgSize){
    return List.generate(9, (int colNumber){
        return sudokuCell(rowNumber, colNumber, imgSize, resp[rowNumber][colNumber],resp);
    });
  }

  List <TableRow> getTableRows(double imgSize){
    return List.generate(9, (int rowNumber){
      return TableRow(children:getRow(rowNumber,imgSize));
    });
  }

  Widget correctionBox(double imgSize){
    return Container(
      height: imgSize,
      width: imgSize,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.symmetric(outside:BorderSide(width: 3, color: Color.fromRGBO(	63, 61, 86,1)),inside:BorderSide(width: 1, color: Color.fromRGBO(	63, 61, 86,1))),
      children: getTableRows(imgSize)
    ));
  }

  getImgHeight(Size size,double imgSize) {
    var total = size.height*0.675;
    var img = (size.height*0.25)/2 + imgSize;
    var gap = (total-img)*0.05;
    return img+gap;
  }

  getButtonHeight(Size size,double imgSize) {
    var total = size.height*0.675;
    var img = (size.height*0.25)/2 + imgSize;
    var gap = (total-img)*0.1;
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
        body: ListView(
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
                      page: SudoMagic(),
                      maxRadius: size.height*1.17,
                      centerAlignment: Alignment.topRight,),
                    );
                        }, 
                        child: Icon(Icons.home,size:32.0,color:Colors.white)
                        ),                  
                        ]),
                  ),
                  flag?SizedBox(height: size.width*0.024,):Container(),
                    flag?Padding(
                      padding: EdgeInsets.all(size.width*0.048),
                      child: SpeechBubble(
                        nipLocation: NipLocation.BOTTOM,
                        nipHeight: 20.0,
                        child: Text('Hello Human! I am the AI that powers this app. I strive to be better always, but like humans I am prone to errors. I have recogonized my error, down below you have an editable sudoku box, feel free to correct my mistakes.',
                      style: TextStyle(fontFamily: 'Pokemon', fontSize: 10, height: 1.5),
                      ),
                      color: Colors.white,
                      ),
                    ):Container(),
                  flag?SizedBox(height: size.height*0.68 - getCardHeight(size, imgSize)):
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
                      backgroundColor: flag?Colors.red:Colors.blue,
                      radius: size.height*0.069
                    ),
                       ),
                    flag? 
                    Positioned(
                    top: (size.height*0.25)/2,
                    left: (size.width-imgSize)/2,                     
                    child: correctionBox(imgSize)):
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
                    flag? Container():
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
                      flag? Container():
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
                      flag? Positioned(
                        top:getButtonHeight(size,imgSize),
                        right: (size.width)/2-45,
                        child: Container(
                      decoration: BoxDecoration(
                      color: Color.fromRGBO(	63, 61, 86,1),
                      borderRadius: BorderRadius.circular(10.0)
                ),
                child: FlatButton.icon(
                  onPressed: () {
                 Navigator.push(
                context,
                  RevealRoute(
                  page: Reloading(size,resp),
                  maxRadius: size.height*1.17,
                  centerAlignment: Alignment.bottomCenter,),
                );                     
                  }, 
                  icon: Icon(Icons.touch_app, color: Colors.white,), 
                  label: Text(
                    'Fix',
                    style: TextStyle(color:Colors.white,fontFamily: 'Quicksand'),
                  ))
                        )
                      ): Container()
                    ],
                  )
        ]
      ,),
    )
    ));
  }
}








