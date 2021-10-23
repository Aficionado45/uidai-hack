import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome.dart';
import 'screens/op_login.dart';
import 'screens/op_otp.dart';
import 'screens/scan.dart';
import 'screens/user_login.dart';
import 'screens/user_otp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'welcome',
      routes: {
        'welcome': (context) => WelcomeScreen(),
        'oplogin': (context) => opLogin(),
        'opotp': (context) => opOTP(),
        'userotp': (context) => userOTP(),
        'userlogin': (context) => userLogin(),
        'scan': (context) => scanDoc(),
      },
    );
  }
}