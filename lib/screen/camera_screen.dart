import 'package:flutter/material.dart';
import 'package:optiguide/screen/top_image_viewer.dart';

import 'camera_viewer.dart';
import 'capture_button.dart';




class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CameraViewer(),
        CaptureButton(),
        TopImageViewer()
      ],
    );
  }
}
