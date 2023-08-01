import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:tflite/tflite.dart';
class PhotoScreen extends StatefulWidget {
  PhotoScreen(this.camera, {super.key});
   List<CameraDescription> camera=[];

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController controller;



  @override
  void initState(){
    controller=CameraController(widget.camera[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if(!mounted){
        return;
      }
      setState(() {

      });

    });
  }


  List<CameraDescription> camera=[];
  @override
  void dispost () {
    controller.dispose();
     Tflite.close();
  }
  late bool   isCapturing;
  void capturePhoto()async{
    if(!controller.value.isInitialized){
      return;
    }


    final Directory appDir=await getApplicationSupportDirectory();
    final String capturePath=p.join(appDir.path,
    '${DateTime.now()}.jpg'
        );
    if(controller.value.isTakingPicture){
      return;
    }
    try{
      setState(() {
         isCapturing=true;

      });

      final XFile capturedImage=await controller.takePicture();
        String imagePath=capturedImage.path;
        await GallerySaver.saveImage(imagePath);
        print("Photo captured and saved to the gallery");

    }
    catch(e){
      print("Error capturing photo $e");
    }
    finally
        {
          setState(() {
            isCapturing=false;
          });
        }
  }
  @override
  Widget build(BuildContext context) {
    return
      SafeArea(child: Scaffold(
        body: Stack(
          children: [

            Positioned.fill(child:
            CameraPreview(controller)),
            Positioned(
              bottom: 0,
                left: 0,
                right: 0,
                child:Container(
                  height: 150,

                child:

                Column(
              children: [
                Padding(

                  padding: const EdgeInsets.all(10.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      Expanded(
                        child: Center(
                          child: Text("camera",style: TextStyle(
                              color: Colors.white
                          ),),
                        ),
                      ),

                  ]),
                ),
                Expanded(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [

                          Expanded(
                            child: InkWell(
                             onTap: () {
                               capturePhoto();
                             //  loadModel();
                             },
                              child: Center(
                                child: Container(
                                  height: 70,
                                  width: 70,

                                  decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                      style: BorderStyle.solid,

                                    )
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                )
              ],
            )))
          ],
        ),
      ));
  }
}
