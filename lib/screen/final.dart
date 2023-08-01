import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:tflite/tflite.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String answer = "";
  int num=0;
  bool press=false;
  final db=FirebaseDatabase.instance.reference();
  CameraController? cameraController;
  CameraImage? cameraImage;
  final RxBool _isInitialized = RxBool(false);
  bool get isInitialized => _isInitialized.value;
  int imageCount=0;
  late List<CameraDescription> _cameras;
//  change the model name in main file at line number 35,36
  loadmodel() async {
    Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }



  initCamera() {

    // cameraController = CameraController(cameras![0], ResolutionPreset.medium);

    // OR
    cameraController = CameraController(
        CameraDescription(
          name: '0', // 0 for back camera and 1 for front camera
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 0,
        ),
        ResolutionPreset.medium);






    cameraController!.initialize().then(
          (value) {
        if (!mounted) {
          return;
        }
        setState(
              () {
            cameraController!.startImageStream(
                  (image) => {
                if (true)
                  {
                    // setState(
                    //   () {
                    //     cameraImage = image;
                    //   },
                    // ),
                    cameraImage = image,

                    applymodelonimages(),
                  }
              },
            );
          },
        );
      },
    );
  }


  applymodelonimages() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map(
                (plane) {
              return plane.bytes;
            },
          ).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 3,
          threshold: 0.1,
          asynch: true);

      answer = '';
      if(predictions!=null){
        // print("**************predictions****************");
        // print(predictions);
        print("**************confidence****************");
        print(predictions[0]['confidence']);
        print("**************label****************");
          print(predictions[0]['label']);
        db.child(predictions[0]['label'].toString()).set({"switch":num},);
        setState(() {
          press=!press;
          press?num=1:num=0;

          print(num);
          print(press)

          ;
          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhotoScreen(camera),))  ;
        });
        }
      // print("**************predictions****************");
      // print(predictions);
      // predictions!.forEach(
      //       (prediction) {
      //     answer +=
      //         prediction['label'].toString().substring(0, 1).toUpperCase() +
      //             prediction['label'].toString().substring(1) +
      //             " " +
      //             (prediction['confidence'] as double).toStringAsFixed(3) +
      //             '\n';
      //   },
      // );

      setState(
            () {
          answer = answer;
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    loadmodel();
  }

  @override
  void dispose() async {
    super.dispose();

    await Tflite.close();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
      ThemeData(brightness: Brightness.dark, primaryColor: Colors.purple),
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: cameraImage != null
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.blue,
            child: Stack(
              children: [
                Positioned(
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(
                          cameraController!,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.black87,
                      child: Center(
                        child: Text(
                          answer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
              : Container(),
        ),
      ),
    );
  }
}