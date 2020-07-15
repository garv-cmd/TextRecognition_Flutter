import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  bool isImageLoaded = false;
  bool ischeck = false;
  String str = ' ';
  Future pickImage() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = File(tempStore.path);
      str = ' ';
      isImageLoaded = true;
    });
  }

  Future readText() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          print(element.text);
          setState(() {
            str = str + element.text + " ";
            ischeck = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isImageLoaded
              ? Center(
                  child: Image(
                  height: MediaQuery.of(context).size.height - 200,
                  width: MediaQuery.of(context).size.width - 50,
                  image: FileImage(pickedImage),
                ))
              : Container(),
          RaisedButton(
            child: Text('Pick an Image'),
            onPressed: pickImage,
          ),
          RaisedButton(
            child: Text('Read Text'),
            onPressed: readText,
          ),
          RaisedButton(
            child: Text('Display Text'),
            onPressed: _showDialog,
          )
        ],
      ),
    );
  }

  void _showDialog() {
    slideDialog.showSlideDialog(
      context: context,
      child: Container(
        width: MediaQuery.of(context).size.width - 70,
        child: SelectableText(str),
      ),
    );
  }
}
