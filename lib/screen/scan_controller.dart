import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:tflite/tflite.dart';


class ScanController extends GetxController {

  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  final RxBool _isInitialized = RxBool(false);
  CameraImage? _cameraImage;
  final RxList<Uint8List> _imageList = RxList([]);


  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized.value;
  List<Uint8List> get imageList => _imageList;

  int imageCount=0;
  @override
  void dispose() {
    _isInitialized.value = false;
    _cameraController.dispose();
    super.dispose();
  }


  Future<void> _initTensorFlow() async {
    String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",

        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
    print("yess");


  }
  Future<void> objectRecognition(CameraImage cameraImage) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        // required
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        // defaults to 127.5
        imageStd: 127.5,
        // defaults to 127.5
        rotation: 90,
        // defaults to 90, Android only
        numResults: 2,
        // defaults to 5
        threshold: 0.1,
        // defaults to 0.1
        asynch: true // defaults to true
    );
    if(recognitions!=null){
      if(recognitions[0]['confidence']>70){
        print(recognitions[0]['label']);
      }
    }
    print(recognitions);
  }
  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.bgra8888);
    _cameraController.initialize().then((value) {
      _isInitialized.value = true;
      _cameraController.startImageStream((image) {
        imageCount++;
        if(imageCount%50==0){
          imageCount=0;
          objectRecognition(image);
        }

      });

      _isInitialized.refresh();
    })
        .catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void onInit() {
    initCamera();
    _initTensorFlow();
    super.onInit();
  }


}




