import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/register_using_phone.dart';
import 'package:helpme/screens/sign_in_and_up/sign_in/sign_in.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Sign extends StatefulWidget {
  @override
  _SignState createState() => _SignState();
}

class _SignState extends State<Sign> {
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: infoWidget.screenWidth * 0.16,
                    ),
                    Container(
                        child: Center(
                            child: Hero(
                                tag: 'splash',
                                child: Image.asset('assets/Logo.png',
                                    fit: BoxFit.fill,
                                    width: infoWidget.orientation ==
                                            Orientation.landscape
                                        ? infoWidget.localWidth * 0.2
                                        : infoWidget.localWidth * 0.28)))),
                    SizedBox(
                      height: 15.0,
                    ),
                    ColorizeAnimatedTextKit(
                        totalRepeatCount: 9,
                        pause: Duration(milliseconds: 1000),
                        isRepeatingAnimation: true,
                        speed: Duration(seconds: 1),
                        text: [translator.currentLanguage == "en" ?' Es3fni ':'اسعفنى'],
                        textStyle: TextStyle(
                            fontSize: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.05:infoWidget.screenWidth * 0.032,
                            fontWeight: FontWeight.bold),
                        colors: [
                          Colors.red,
                          Colors.indigo,
                          Colors.red,
                          Colors.indigo,
                          Colors.red,
                        ],
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional
                            .topStart // or Alignment.topLeft
                    ),
                    SizedBox(
                      height: infoWidget.screenWidth * 0.4,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegisterUsingPhone()));
                      },
                      color: Colors.indigo,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        child: Text(
                          translator.currentLanguage == "en" ?'Create Account':'حساب جديد',
                          style: infoWidget.titleButton,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    SizedBox(height: 15,),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignIn()));
                      },
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        child: Text(
                          translator.currentLanguage == "en" ?'Login':'تسجيل الدخول',
                          style: infoWidget.titleButton
                              .copyWith(color: Colors.indigo),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),side: BorderSide(color: Colors.indigoAccent)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
