import 'package:aadhar_address/screens/scan.dart';
import 'package:aadhar_address/screens/user_login.dart';
import 'package:aadhar_address/utils/feedback_form.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class capture extends StatefulWidget {
  const capture();

  @override
  _captureState createState() => _captureState();
}

void updateData() {
  var db = FirebaseFirestore.instance;
  DateTime curr = DateTime.now();
  db.collection("ongoing").doc(userRefId).update({
    "step": 4,
    "timestamp": curr,
  });
}

// Pick image from camera
Future pickImageFromCamera(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  try {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: MediaQuery.of(context).size.height / 4,
      maxWidth: MediaQuery.of(context).size.height / 3.5,
    );
    return pickedFile;
  } catch (err) {
    print(err);
  }
}

// Upload image file to destination on Firebase Storage
// : if request.auth != null;
Future<void> uploadImage(File image, String storageDestinationPath) async {
  try {
    await FirebaseStorage.instance.ref(storageDestinationPath).putFile(image);
  } on FirebaseException catch (err) {
    print(err.toString());
  }
}

File userImage;
File operatorImage;

class _captureState extends State<capture> {
  bool userUploaded = false;
  bool operatorUploaded = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: MediaQuery.of(context).size.height / 8,
          elevation: 0,
          leadingWidth: MediaQuery.of(context).size.width / 4,
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Hero(
              tag: 'logo',
              child: Image(
                image: AssetImage('images/Aadhaar_Logo.svg'),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help_outline_rounded,
                color: Color(0xFF143B40),
                size: 30,
              ),
              onPressed: () {
                getFeedback(context);
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                "Capture User and Operator Images",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Open Sans'),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      userUploaded
                          ? Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.height / 4,
                              child: Image(
                                image: FileImage(
                                  userImage,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              size: MediaQuery.of(context).size.height / 6,
                            ),
                      Text(
                        'User',
                        style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () async {
                            final PickedFile newImage =
                                await pickImageFromCamera(context);
                            setState(() {
                              if (newImage != null) {
                                userImage = File(newImage.path);
                                userUploaded = true;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xFF143B40),
                          ),
                          iconSize: MediaQuery.of(context).size.height / 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      operatorUploaded
                          ? Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.height / 4,
                              child: Image(
                                image: FileImage(
                                  operatorImage,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person_outline_rounded,
                              size: MediaQuery.of(context).size.height / 6,
                            ),
                      Text(
                        'Operator',
                        style: TextStyle(
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () async {
                            final PickedFile newImage =
                                await pickImageFromCamera(context);
                            setState(() {
                              if (newImage != null) {
                                operatorImage = File(newImage.path);
                                operatorUploaded = true;
                              }
                            });
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            color: Color(0xFF143B40),
                          ),
                          iconSize: MediaQuery.of(context).size.height / 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF143B40),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: FractionalOffset.center,
                    width: MediaQuery.of(context).size.width / 4,
                    height: 40,
                    child: FlatButton(
                      onPressed: () async {
                        setState(() {
                          error = false;
                        });
                        Navigator.pushReplacementNamed(context, 'confirmation');
                      },
                      child: Text(
                        "Reset",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF143B40),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: FractionalOffset.center,
                    width: MediaQuery.of(context).size.width / 4,
                    height: 40,
                    child: FlatButton(
                      onPressed: () async {
                        if (userUploaded && operatorUploaded) {
                          setState(() {
                            error = false;
                          });

                          await uploadImage(userImage, '$userRefId/user.png');

                          await uploadImage(
                              operatorImage, '$userRefId/operator.png');
                          Navigator.pushNamed(context, "confirm");
                        } else {
                          setState(() {
                            error = true;
                          });
                        }
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                'Please capture both images',
                style: TextStyle(
                    color: error ? Colors.red : Colors.white,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}


//TODO: Improve UI
//Show Error messages