import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/register_using_phone.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../../models/http_exception.dart';
import '../../home_screen.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {


  String errorMessage;
  bool _isSignInUsingFBSuccessful=false;
  bool _isSignInUsingGoogleSuccessful=false;
  bool _isSignInUsingPhoneSuccessful=false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  var loggedIn = false;
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget){
        return SafeArea(
          child: Scaffold(
            body:
            SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: infoWidget.screenWidth * 0.16,
                      ),
                      Image.asset('assets/Logo.png',
                          fit: BoxFit.fill,
                          width: infoWidget.orientation ==
                              Orientation.landscape
                              ? infoWidget.localWidth * 0.2
                              : infoWidget.localWidth * 0.28),
                      SizedBox(
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RaisedButton(
                          color: Colors.indigo,
                          onPressed:
                          _isSignInUsingPhoneSuccessful?(){}:() async{
                            setState(() {
                              _isSignInUsingPhoneSuccessful=true;
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _isSignInUsingPhoneSuccessful?Center(child: CircularProgressIndicator(),):Row(
                              children: <Widget>[
                                ImageIcon(
                                  AssetImage('assets/phone.png'),
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    translator.currentLanguage == "en"
                                        ? 'Continue with Phone Number':'الدخول عن طريق الهاتف',
                                    textAlign: TextAlign.center,
                                    style: infoWidget.titleButton,
                                ),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed:
                              () async{
                            setState(() {
                              _isSignInUsingGoogleSuccessful=true;
                            });
                        bool x = await Provider.of<Auth>(context, listen: false).signInUsingFBorG('G');
                        if(x==false){
                          Toast.show(translator.currentLanguage == "en"
                              ? "Please try again!":'من فضلك حاول اخرى', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                          setState(() {
                            _isSignInUsingGoogleSuccessful=false;
                          });
                        }else{
                          Toast.show(translator.currentLanguage == "en"
                              ? "successfully Sign In":'نجح تسجيل الدخول', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomePage()));
                        }
//
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _isSignInUsingGoogleSuccessful?Center(child: CircularProgressIndicator(),):Row(
                              children: <Widget>[
                                ImageIcon(
                                  AssetImage('assets/google.png'),
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    translator.currentLanguage == "en"
                                        ? 'Continue with Google':'الدخول عن طريق حساب جوجل',
                                    textAlign: TextAlign.center,
                                    style: infoWidget.titleButton,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                       RaisedButton(
                         color: Colors.blue[900],
                         onPressed: () async{
                           setState(() {
                             _isSignInUsingFBSuccessful=true;
                           });
                           await Provider.of<Auth>(context, listen: false).signInUsingFBorG("FB").then((x){
                             if(x==false){
                               Toast.show(translator.currentLanguage == "en"
                                   ? "Please try again!":'من فضلك حاول اخرى', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                               setState(() {
                                 _isSignInUsingFBSuccessful=false;
                               });
                             }else{
                               Toast.show(translator.currentLanguage == "en"
                                   ? "successfully Sign In":'نجح تسجيل الدخول', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                               Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomePage()));
                             }
                           });
                         },
                         shape: RoundedRectangleBorder(
                             borderRadius:
                                 BorderRadius.all(Radius.circular(10))),
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: _isSignInUsingFBSuccessful?Center(child: CircularProgressIndicator(),):Row(
                             children: <Widget>[
                               ImageIcon(
                                 AssetImage(
                                   'assets/facebook.png',
                                 ),
                                 color: Colors.white,
                               ),
                               Expanded(
                                 child: Text(
                                   translator.currentLanguage == "en"
                                       ? 'Continue with Facebook':'الدخول عن طريق حساب الفيس بوك',
                                   textAlign: TextAlign.center,
                                   style: infoWidget.titleButton,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          textDirection:  translator.currentLanguage == "en"
                              ? TextDirection.ltr:TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              translator.currentLanguage == "en"
                                  ? 'Register with phone ':'تسجيل برقم الهاتف ',
                              style:
                              infoWidget.subTitle,
                            ),
                            InkWell(
                              onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegisterUsingPhone()));
                              },
                              child: Text(
                                translator.currentLanguage == "en"
                                    ? 'Register!':'!سجل',
                                style: infoWidget.subTitle.copyWith(color: Colors.indigo),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}