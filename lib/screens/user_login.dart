import 'dart:typed_data';
import 'package:aadhar_address/screens/user_otp.dart';
import 'package:aadhar_address/services/authentication_methods.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class userLogin extends StatefulWidget {
  const userLogin();

  @override
  _userLoginState createState() => _userLoginState();
}

String userRefId;

class _userLoginState extends State<userLogin> {
  bool error = false;
  Image captchaimage;
  var captchatxnid;
  String otpmessage;
  TextEditingController captchafield = new TextEditingController();
  bool errorcaptcha = false;
  @override
  String user_aadhar;

  Future<int> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('ongoing');
      var doc = await collectionRef.doc(docId).get();
      if (doc.exists) {
        int step = doc.get('step');
        return step;
      } else
        return 0;
    } catch (e) {
      throw e;
    }
  }

  void generateRefID() {
    var bytes = utf8.encode(user_aadhar);
    var digest = sha1.convert(bytes);
    userRefId = digest.toString();
    userRefId = userRefId.substring(0, 10);
    print("User Ref ID: $userRefId");
  }

  void addUser(String id) {
    var db = FirebaseFirestore.instance;
    DateTime curr = DateTime.now();
    db.collection("ongoing").doc(id).set({
      "step": 1,
      "transactionID": id,
      "timestamp": curr,
    });
  }

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
        ),
        backgroundColor: Colors.white,
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width / 1.3,
                height: MediaQuery.of(context).size.height / 13.6,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Open Sans',
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty)
                      return null;
                    else {
                      user_aadhar = value;
                    }
                  },
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          // color: Colors.redAccent,
                          width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          // color: Colors.redAccent,
                          width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    filled: true,
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                    labelText: "User Aadhaar Number",
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF143B40),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: FractionalOffset.center,
                width: MediaQuery.of(context).size.width / 3,
                height: 40,
                child: FlatButton(
                  onPressed: () async {
                    if (user_aadhar != null && user_aadhar.length == 12) {
                      Map<String, dynamic> responsebody = await getcaptcha();
                      //decoding response
                      setState(() {
                        error = false;
                        var captchaBase64String =
                            responsebody["captchaBase64String"];
                        captchatxnid = responsebody["captchaTxnId"];
                        Uint8List bytes =
                            Base64Decoder().convert(captchaBase64String);
                        captchaimage = Image.memory(bytes);
                      });
                      setState(() {
                        error = false;
                      });

                      // Navigator.pushNamed(context, 'userotp', arguments: step);
                    } else {
                      setState(() {
                        error = true;
                      });
                    }
                  },
                  child: Text(
                    "Get Captcha",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 30,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30),
              if (captchaimage != null)
                Column(
                  children: [
                    captchaimage,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: MediaQuery.of(context).size.width / 1.3,
                      height: MediaQuery.of(context).size.height / 13.6,
                      child: TextFormField(
                        controller: captchafield,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                // color: Colors.redAccent,
                                width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                // color: Colors.redAccent,
                                width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          filled: true,
                          labelStyle:
                              TextStyle(color: Colors.black, fontSize: 20),
                          labelText: "Enter Captcha",
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF143B40),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      alignment: FractionalOffset.center,
                      width: MediaQuery.of(context).size.width / 3,
                      height: 40,
                      child: FlatButton(
                        onPressed: () async {
                          final uuidno = uuid.v4();
                          Map<String, dynamic> responsebody = await getotp(
                              uuidno,
                              user_aadhar,
                              captchafield.text,
                              captchatxnid);
                          print(responsebody);
                          setState(() {
                            responsebody["message"] ==
                                    "OTP generation done successfully"
                                ? errorcaptcha = false
                                : errorcaptcha = true;
                            otpmessage = responsebody["message"];
                          });
                          if (errorcaptcha == false) {
                            generateRefID();
                            int step = await checkIfDocExists(userRefId);
                            if (step == 0) {
                              addUser(userRefId);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => userOTP(
                                    aadharno: user_aadhar,
                                    txnid: responsebody["txnId"],
                                    step: step),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Verify Captcha",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width / 35,
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // FlatButton(
                    //   onPressed: () async {
                    //     Navigator.pushNamed(context, 'opotp');
                    //   },
                    //   child: Text(
                    //     "move to next screen",
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //       fontSize: 20,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              Text(
                'Please enter a valid 12 digit Aadhaar Number',
                style: TextStyle(
                    color: error ? Colors.red : Colors.white,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold),
              ),
              if (otpmessage != null)
                Text(
                  otpmessage,
                  style: TextStyle(
                      color: errorcaptcha ? Colors.red : Colors.white,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold),
                ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

//TODO: Improve UI
//Error for wrong input format less than 12 digits
//Auth API integration
