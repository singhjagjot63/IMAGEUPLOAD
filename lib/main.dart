import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _selectedFile;
  String greetings = '';
  // static final String uploadEndPoint = 'http://192.168.137.1/saveFile.php';
  String status = "";
  bool _inProcess = false;
  String base64Image;
  File tmpFile;
  String errMessage = "Error Uploading Image";
  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/placeholder.jpg",
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "RPS Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        _selectedFile = File(cropped.path);
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }

    tmpFile = _selectedFile;
    //base64Image = base64Encode(_selectedFile.readAsBytesSync());
  }

  /* setStatus(String message) {
    setState(() {
      status = message;
    });
  }*/

  startUpload() async {
    final uri = Uri.parse("http://192.168.1.9:80/upload_image.php");
    var request = http.MultipartRequest('POST', uri);
    var pic = await http.MultipartFile.fromPath("image", _selectedFile.path);

    request.files.add(pic);

    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Image Uploaded');
    } else {
      print('Image not uploaded');
    }
  }

  testing() async {
    final response = await http.get('http://192.168.1.9:5000/');
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    setState(() {
      greetings = decoded['greetings'];
    });
    print(greetings);
  }

  /*upload(String fileName) {
    http.post(uploadEndPoint, body: {
      "file": base64Image,
      "name": fileName,
    }).then((result) {
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getImageWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                    color: Colors.green,
                    child: Text(
                      "Camera",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      getImage(ImageSource.camera);
                    }),
                MaterialButton(
                    color: Colors.deepOrange,
                    child: Text(
                      "Device",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    }),
                MaterialButton(
                    color: Colors.blue,
                    child: Text(
                      "Upload",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      startUpload();
                    }),
                MaterialButton(
                    color: Colors.blue,
                    child: Text(
                      "Test",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      testing();
                    }),
              ],
            ),
            Center(child: Text(greetings))
          ],
        ),
        (_inProcess)
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height * 0.95,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Center()
      ],
    ));
  }
}
