import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:provider/provider.dart';

import 'sign_in_and_up/sign_in_and_up.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Auth _auth;

  @override
  void initState() {
    _auth = Provider.of<Auth>(context,listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InfoWidget(
        builder: (context,infoWidget){
          return Scaffold(
            body: Container(color: Colors.red,
            height: infoWidget.screenHeight,
            width: infoWidget.screenWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Home'),
                RaisedButton(onPressed: ()async{
                 bool x =  await _auth.logout();
                 if(x){
                   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> Sign()));
                 }
                },
                child: Text('log out'),
                )
              ],
            ),),
          );
        },
      ),
    );
  }
}
