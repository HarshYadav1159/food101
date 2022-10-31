import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<File>? imagefile ;
  File? _image;
  String result ="";
  ImagePicker? imagePicker;
  double max =0;

  @override
  void initState(){
    super.initState();
    imagePicker = ImagePicker();
    loadModel();
  }

  // pickImage(ImageSource source)async{
  //   final ImagePicker _imagePicker = ImagePicker();
  //   XFile? _file = await _imagePicker.pickImage(source: source,imageQuality: 85);
  //
  //   if(_file!=null){
  //     XFile image = XFile(_file.path);
  //     return await _file.readAsBytes();
  //
  //   }
  //   print('No image selected');
  // }

  Future foodClassification()async{
    var recognition = await Tflite.runModelOnImage(
        path: _image!.path,
        threshold: 0.1,
        asynch: true
    );
    // setState(() {
    //   result = recognition;
    // });
    print(recognition?.toString());
    setState(() {
      result ="";
      max = 0;
    });

    recognition?.forEach((element) {
      setState(() {
        print(element.toString());
        if(element["confidence"]>max){
          result =element["label"];
          max = element["confidence"];
        }
      });
    });

  }

  Future loadModel()async{
    Tflite.close();
    String? output = await Tflite.loadModel(
        model: 'assets/tf_lite_model.tflite',
        labels: 'assets/labels.txt',
        isAsset: true,
        numThreads: 1
    );
    print("Progress: $output");
  }
  selectPhoto()async{
    PickedFile? pickedFile = await imagePicker?.getImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      foodClassification();
    });

  }

  capturePhoto()async{
    PickedFile? pickedFile = await imagePicker?.getImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      foodClassification();
    });

  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(centerTitle: true,
          title: Text('Food101'),
        ),
        body: Column(
          children: [
            Container(
                color: Colors.grey,
                height: 500,
                width: 400,
                child:(_image!=null)?Image.file(_image!,
                  fit: BoxFit.cover,):Text("no")
            ),
            Column(
              children: [
                Text(result),
                FloatingActionButton(
                  onPressed: selectPhoto,
                  child: Text("P"),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

