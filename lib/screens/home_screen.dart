import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InfoWidget(
        builder: (context,infoWidget){
          return Scaffold(
            body: Container(color: Colors.red,),
          );
        },
      ),
    );
  }
}
