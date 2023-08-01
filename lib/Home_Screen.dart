import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:optiguide/screen/photo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool press=false;
  List<CameraDescription> camera=[];
  int num=0;
  final db=FirebaseDatabase.instance.reference();
  @override
  Widget build(BuildContext context) {



    return SafeArea(child:
    Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            minimumSize: const MaterialStatePropertyAll(Size(200,50)),
              backgroundColor: MaterialStatePropertyAll(
            press? Colors.yellow:    Colors.black
              )
          ),
          child: Text( press?"ON":"OFF"),
          onPressed: () {
            db.child("light").set({"switch":num},);
            setState(() {
              press=!press;
              press?num=1:num=0;

print(num);
              print(press)
              
;
  //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PhotoScreen(camera),))  ;
            });

          },
        ),
      )
    ));
  }
}
