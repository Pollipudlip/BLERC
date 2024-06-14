//import 'dart:js';
//import 'dart:js';

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';


void main() {
  final game = FlameGame();
  //runApp(GameWidget(game: game));
  runApp(const MainApp());
}


class MainApp extends StatelessWidget{
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    const appTitle = 'BLE RC';
    return  MaterialApp(
        title: appTitle,
        home: OrientationFrame(
          title: appTitle,
        ),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey,brightness: Brightness.dark),
        ),
    );
  }
  
}

class OrientationFrame extends StatelessWidget{
  
  final String title;
 // final SvgTheme steeringTheme = SvgTheme(currentColor: Colors.grey);
  
  const OrientationFrame({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    
  return Scaffold(
     // appBar: AppBar(title: Text(title)),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if(orientation == Orientation.landscape){
              //3 main columns
              return Row(
                

                children: [
                //MyImage(assetImage: const AssetImage('assets/steering-wheel-icon.svg')),
                 //Image.asset('assets/steering-wheel-icon.png'),
                Expanded(child: steeringWidget()),
                 //SvgPicture.asset('assets/steering-wheel-icon.svg',color: Colors.grey,),
                 Expanded(child:  TestCard(myContent: 'center console')),
                 Expanded(child:  gasBreakWidget(),
                  )
                ],
              );
          

            //return TestCard(myContent: 'Landscape view bitch');
          }else if (orientation == Orientation.portrait){
            return GridView.count(
                crossAxisCount: 1,
                children: [TestCard(myContent: 'Bluetooth settings'),
                ]
              );
            
            
          }
          else{
            return TestCard(myContent: 'The Fuck?');
          }
        },
      )
  );
  
  }
  
}

/** Steernig */

class steeringWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _steeringState();
  
  
}

class _steeringState extends State<steeringWidget>{

  double morning_angle =0;
 
  @override
  Widget build(BuildContext context) {
    
  return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.rotationZ(morning_angle),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              morning_angle = calc().steeringAngle(context.size!.width, details.localPosition.dx);
            });
          },
          onHorizontalDragStart: (details) {
            morning_angle = calc().steeringAngle(context.size!.width, details.localPosition.dx);
          },

          child:Image.asset('assets/steering-wheel-icon.png',fit: BoxFit.contain,),

        )
        
      )                 
      );
  }
  
}

/** Gas and Break */

class gasBreakWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _gasBreakState();
}

class _gasBreakState extends State<gasBreakWidget>{
  double _position =0.6;
  double _width =0;
  double _height =0;
  double _aspect = 0;
  Color indicatorColor =Colors.white;


  Image acceleratorImage = Image.asset('assets/gas_break_2.png',fit: BoxFit.fitHeight,alignment: Alignment.centerRight,);

  
  //ui.Image acceleratorImage = .drawCircle(Offset.zero, 50, Paint());
  //Future <ui.Image> acceleratorImage =   decodeImageFromList(File('assets/gas_break.png',).readAsBytesSync());
  //decodeImageFromList(File('assets/gas_break.png',).readAsBytesSync());
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = acceleratorImage.width != null ? acceleratorImage.width! : MediaQuery.of(context).size.width;
    //_aspect = acceleratorImage
    //acceleratorImage.frameBuilder
    return  Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            //_aspect= details.sourceTimeStamp!.inSeconds.ceilToDouble();
            setState(() {
              _position = calc().gasPosition(_height,details.localPosition.dy); //details.localPosition.dy;
              indicatorColor = updateColor(_position);
              //acceleratorImage = gasBreakDynamic(_position);
              _width = acceleratorImage.width != null
                  ? acceleratorImage.width!
                  : MediaQuery.of(context).size.width;
              //_position = details.localPosition.dy;
            });
          },
          child: Container(
            width: _width,
            height: _height,
            child:

                //gasBreakDynamic(_position),
                // Image.asset('assets/gas_break.png',fit: BoxFit.contain,alignment: Alignment.centerRight,color: Colors.blueGrey,),

                Stack(fit: StackFit.passthrough, children: [
              //gasBreakDynamic(_position),

              CustomPaint(
                painter: progressPainter(_position,Theme.of(context).colorScheme.surfaceVariant),
                size: Size.fromWidth(
                    _width), //acceleratorImage.width!= null ? Size.fromWidth(acceleratorImage.width! ) : Size.infinite,
              ),
              Image.asset(
                'assets/gas_break_2.png',
                fit: BoxFit.fitHeight,
                alignment: Alignment.centerRight,
                color: Theme.of(context).colorScheme.background,
              ),
              Image.asset(
                'assets/break4_3.png',
                fit: BoxFit.fitHeight,
                alignment: Alignment.centerRight,
                color: indicatorColor,
              ),
              //acceleratorImage,
              //gasBreakDynamic(_position),
              //Expanded(child:Image.asset('assets/gas_break.png',fit: BoxFit.contain,alignment: Alignment.centerRight,),),
              //acceleratorImage,
              // Image.asset('assets/gas_break.png',fit: BoxFit.none,),
              // Expanded(child:CustomPaint(painter:  progressPainter(_position)),),
              //RotatedBox(quarterTurns: -1, child: LinearProgressIndicator(value: _position,),),
              /*ListView(
              children: [
                Text(_width.toString()),
                Text(_height.toString()),
                Text(_position.toString()),
                Text(_aspect.toString()),
              ],

            )*/

              //Text(_position2.toString()),
            ]),
          ),
        ),
        // Expanded(child: Image.asset('assets/gas_break.png',fit: BoxFit.contain,alignment: Alignment.centerRight,)),
      
    );
  }
}
Color updateColor(double input) {

  int code = (input*229+26).ceil() ;
  code = code << 24;
  code = code | 0xFFFFFF;

  return Color(code);
}

Image gasBreakDynamic (double input){
  Image toRet;
  if(input > 0.5) toRet = Image.asset('assets/gas_break_2.png',fit: BoxFit.contain,alignment: Alignment.centerRight,color: Colors.blueGrey,);
  else toRet = Image.asset('assets/gas_break_2.png',fit: BoxFit.contain,alignment: Alignment.centerRight,color: Colors.grey,);

  return toRet;
}

/** Misc */

class TestCard extends StatelessWidget {
  const TestCard({
    super.key,
    required this.myContent,
  });

  final myContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary,);
    return Card(
      color: theme.colorScheme.primary,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(myContent,style: style,textAlign: TextAlign.center,),
      ),
    );
  }
}

class progressPainter extends CustomPainter{
  double value;
  Color color;
 // ui.Image _image;
  //Future <ui.Image> _imageTemp;
  //ui.Image _image = ;
  progressPainter(this.value,this.color);

  
  


  @override
  void paint(Canvas canvas, Size size)
  //..color = Colors.green
   {
    
    //_imageTemp.whenComplete(() => null)
    Rect maskBar = Rect.fromPoints(
      Offset(0,size.height*(1-value)*0.9,), 
      Offset(size.width,size.height)
      
      );
      /*
    Rect bar = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height*2*value,      
    );    */

    canvas.drawRect(
      maskBar,
      Paint()..color = color ,
    );

    //canvas.drawImage(_image, Offset.zero, Paint());
  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  
}

class calc {
  double steeringAngle(double range,double value, {double limits = 0.60}){
    double center = range /2;
    double pos = value - range /2;
    double rad = pos / center;
    if (rad > limits) rad = limits;
    else if (rad < -limits) rad = -limits;
    return rad /limits ;
  }

  double gasPosition(double range,double value, {double upperLimit = 0.80,}){
    double toRet = value;
    toRet = value / upperLimit;
    toRet = toRet / range;
    
    toRet = 1-toRet;
    if( toRet < 0.1  ) return 0;
    else if( toRet > 1 ) return 1;
    else return toRet;
  }
}
// <>
/*
class MyImage extends StatefulWidget {
  const MyImage({
    super.key,
    required this.assetImage,
  });

  final AssetImage assetImage;

  @override
  State<MyImage> createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We call _getImage here because createLocalImageConfiguration() needs to
    // be called again if the dependencies changed, in case the changes relate
    // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
    _getImage();
  }

  @override
  void didUpdateWidget(MyImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assetImage != oldWidget.assetImage) {
      _getImage();
    }
  }

  void _getImage() {
    final ImageStream? oldImageStream = _imageStream;
    _imageStream = widget.assetImage.resolve(createLocalImageConfiguration(context));
    if (_imageStream!.key != oldImageStream?.key) {
      // If the keys are the same, then we got the same image back, and so we don't
      // need to update the listeners. If the key changed, though, we must make sure
      // to switch our listeners to the new image stream.
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream!.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      // Trigger a build whenever the image changes.
      _imageInfo?.dispose();
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageInfo?.dispose();
    _imageInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image, // this is a dart:ui Image object
      scale: _imageInfo?.scale ?? 1.0,
    );
  }
}*/