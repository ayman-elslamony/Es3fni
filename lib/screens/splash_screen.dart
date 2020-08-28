import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../core/ui_components/info_widget.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context ,infoWidget)=>Scaffold(
        body:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                child: Center(child: Hero(tag: 'splash',child: Image.asset('assets/Logo.png',fit: BoxFit.fill,width: infoWidget.orientation ==Orientation.landscape?infoWidget.localWidth*0.2:infoWidget.localWidth*0.28)))),
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
          ],
        ),
      ),
    );
  }
}
