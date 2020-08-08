import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_client/cloudinary_client.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:loading/indicator.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:cloudinary_client/models/CloudinaryResponse.dart' as cr;
import 'dart:convert';
import 'package:loading/loading.dart';
import 'credentials.dart' as cred;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reko Cloud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Rekognition with Cloudinary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Making the cloudinary client
  CloudinaryClient client =
      CloudinaryClient(cred.api_key, cred.api_secret, cred.cloud_name);
  String imageUrl;
  bool isLoading = false;
  Image uploadedImagee;

  Future uploadImage() async {
    print("Starting uploading");
    cr.CloudinaryResponse response =
        await client.uploadImage(file.path, folder: 'new_floder 123');
    
    // For debugging
    print(response.secure_url);

    // Dynamically changing the image url and image.
    setState(() {
      isLoading = false;
      imageUrl = response.secure_url;
      uploadedImagee = Image.network(imageUrl);
    });

    // For debugging
    print("Finished uploading");
    print("starting labeling");

    // Getting the labels
    gettingLabels();

    // For debugging
    print("Ending labelling");
  }

  // Variables
  File file;
  var filename = '';
  var output = 0;
  var labels = new List();
  var dataToBeShown = '';

  // Function for getting labels
  void gettingLabels() {
    var data;
    setState(() {});

    // API created on Lambda function and Deployed on API gateway on AWS.
    final String api_link =
        'https://ufbh6l57pc.execute-api.ap-south-1.amazonaws.com/test11-deployment-2-POST/geturl';
    
    // For debugging
    print("Printing url");
    print(imageUrl.toString());

  // Getting response from the API
    http
        .post(api_link,
            body:
                jsonEncode(<String, String>{"url": imageUrl, "name": filename}))
        .then((res) {

      // Converting into correct format
      data = Map.from(json.decode(res.body))['body'];
      data=data.toString().replaceAll("'", "\"");
      data=List.from(Map.from(json.decode(data))["Labels"]);

      // For debugging
      print(data.runtimeType);

      // Hetting only yhr label name
      for (var x in data) {
        print(x["Name"]);
        labels.add(x["Name"]);
      }

      // Dnamically setting the variable to be shown
      setState(() {
        dataToBeShown = labels.toString();
      });

    });
  }

// For choosing the image from the gallery
  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        filename = file.path.split('/').last;
      });
    }
  }

  // Widget for the Cloud icon and function triggering.
  Widget upload_icon() {
    return GestureDetector(
      onTap: () {
        _choose();
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  // Widget for the Analyse container and triggering function.
  Widget upload_button() {
    return GestureDetector(
        onTap: () {
          print("Analyzing starting");
          uploadImage();
        },
        child: Container(
          child: Center(
            child: Text("Analyze"),
          ),
        ));
  }

  // Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),

            // Labels are shown here once we get the response from the API
            Text(
              dataToBeShown,
            ),

            // Widget changes according to the condition
            Container(
              child: filename == '' ? upload_icon() : upload_button(),
            )
          ],
        ),
      ),
    );
  }
}