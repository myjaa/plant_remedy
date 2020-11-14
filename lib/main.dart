import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
      home: DetectMain(),
      debugShowCheckedModeBanner: false,
    ));

class DetectMain extends StatefulWidget {
  @override
  _DetectMainState createState() => new _DetectMainState();
}

class _DetectMainState extends State<DetectMain> {
  File _image;
  double _imageWidth;
  double _imageHeight;
  var _recognitions;
  var remedy = {
    'Cardamom': [
      'REGULARISING HEART RATE\n\nAdd a teaspoonful of cardamom powder to a little honey and have it once or twice a day for the above said benefits.',
      'DIGESTIVE HEALTH\n\nyou can consume the seeds plain, sprinkle ground cardamom on your food or go for a healthy cup of cardamom tea.',
      'COLD and FLU\n\nCardamom tea twice a day when you have symptoms of cold is considered ideal'
    ],
    'Gotu Kola': [
      ' MAY HELP IN IMPROVING COGNITIVE FUNCTIONS\n\nAlthough gotu kola and folic acid were equally beneficial in improving overall cognition, gotu kola was more effective in improving memory domain.How to use: Take 750 to 1,000 mg of gotu kola per day for up to 14 days at a time.',
      'MAY REDUCE ANXIETY & STRESS\n\n Sleep deprivation can cause anxiety, oxidative damage, and neuroinflammation.How to use: Take 500 mg of gotu kola extract twice a day for up to 14 days at a time. You can take up to 2,000 mg per day in cases of extreme anxiety.'
    ],
    'Turmeric': [
      'CUTS, BRUISES & WOUNDS\n\nIf you’ve cut your finger while learning to cook, chances are that someone immediately took out the spice box to put some haldi powder on it. Its antiseptic qualities - some of the health benefits of turmeric - are the reason that this remedy has been effective for generations.',
      'DIGESTION\n\nTurmeric not only helps in building an appetite, it also improves digestion. It helps stimulates the secretion of digestive juices which are essential for proper functioning of the entire digestive system. Hot tea made with turmeric paste, ginger, lemon, and honey is good way to consume turmeric for this benefit',
      'COLD & COUGH\n\nHaldi doodh is a concoction often recommended by elders to tackle the seasonal colds and coughs. To make this drink, spices such as cardamom, pepper, ginger, and cinnamon are added to boiling milk with haldi powder. Honey can also be added as it helps soothe a sore throat. Turmeric’s anti-inflammatory, antiseptic and expectorant properties empower us to fight cold and chest ailments speedily. Turmeric in warm milk is a timeless home remedy.',
      'ACNE & SKIN TROUBLES\n\nA face pack made of besan (gram flour) along with haldi powder and milk can help in reducing the appearance of acne and its scars. This face pack can also help brighten skin and reduce uneven skin tone. Antiseptic, anti-oxidant and anti-inflammatory properties of turmeric provide this benefit. This turmeric pack is a great home remedy for dull skin'
    ]
  };

  loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/ayurveda.tflite",
        labels: "assets/labels.txt",
      );
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  // run prediction using TFLite on given image
  Future predict(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        // required
        imageMean: 0.0,
        // defaults to 117.0
        imageStd: 255.0,
        // defaults to 1.0
        numResults: 2,
        // defaults to 5
        threshold: 0.2,
        // defaults to 0.1
        asynch: true // defaults to true
        );

    print(recognitions);

    setState(() {
      _recognitions = recognitions;
    });
  }

  // send image to predict method selected from gallery or camera
  sendImage(File image) async {
    if (image == null) return;
    await predict(image);

    // get the width and height of selected image
    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
            _image = image;
          });
        })));
  }

  // select image from gallery
  selectFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {});
    sendImage(image);
  }

  // select image from camera
  selectFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {});
    sendImage(image);
  }

  @override
  void initState() {
    super.initState();

    loadModel().then((val) {
      setState(() {});
    });
  }

  Widget printRemedy(rcg) {
    if (rcg == null) {
      return Text('',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    } else if (rcg.isEmpty) {
      return Center(
        child: Text("Could not recognize",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }

    var remedyList = remedy[_recognitions[0]['label'].toString()];
    // var remedyList=remedy['Turmeric'];
    print(remedyList.length);
    print(remedyList);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: remedyList.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            height: 500,
            width: double.maxFinite,
            child: Card(
                color: Colors.lightGreen,
                elevation: 5,
                // child: Center(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 50, 15, 15),
                    child: Text(
                      remedyList[index],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    )))
            // )
            );
      },
    );
  }

  Widget printValue(rcg) {
    if (rcg == null) {
      return Text('',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    } else if (rcg.isEmpty) {
      return Center(
        child: Text("Could not recognize",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Text(
          "Prediction: " + _recognitions[0]['label'].toString().toUpperCase(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // gets called every time the widget need to re-render or build
  @override
  Widget build(BuildContext context) {
    // get the width and height of current screen the app is running on
    Size size = MediaQuery.of(context).size;

    // initialize two variables that will represent final width and height of the segmentation
    // and image preview on screen
    double finalW;
    double finalH;

    // when the app is first launch usually image width and height will be null
    // therefore for default value screen width and height is given
    if (_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    } else {
      // ratio width and ratio height will given ratio to
//      // scale up or down the preview image
      double ratioW = size.width / _imageWidth;
      double ratioH = size.height / _imageHeight;

      // final width and height after the ratio scaling is applied
      finalW = _imageWidth * ratioW * .85;
      finalH = _imageHeight * ratioH * .50;
    }

//    List<Widget> stackChildren = [];

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            "Ayurvedha Remedy",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: printValue(_recognitions),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: _image == null
                  ? Center(
                      child: Text("Select image from camera or gallery"),
                    )
                  : Center(
                      child: Image.file(_image,
                          fit: BoxFit.fill, width: finalW, height: finalH)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    height: 50,
                    width: 150,
                    color: Colors.redAccent,
                    child: FlatButton.icon(
                      onPressed: selectFromCamera,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                      color: Colors.deepPurple,
                      label: Text(
                        "Camera",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  ),
                ),
                Container(
                  height: 50,
                  width: 150,
                  color: Colors.tealAccent,
                  child: FlatButton.icon(
                    onPressed: selectFromGallery,
                    icon: Icon(
                      Icons.file_upload,
                      color: Colors.white,
                      size: 30,
                    ),
                    color: Colors.blueAccent,
                    label: Text(
                      "Gallery",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: printRemedy(_recognitions),
            )
          ],
        ));
  }
}
