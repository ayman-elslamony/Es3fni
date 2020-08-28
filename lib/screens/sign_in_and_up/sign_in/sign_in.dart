import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/register_using_phone.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../../models/http_exception.dart';

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
  Future<void> _submitForm() async {
//    if(!_isSignUp){
//      if (_formKey.currentState.validate()) {
//        _formKey.currentState.save();
//        setState(() {
//          _isSignInSuccessful = true;
//        });
//        try {
//          bool auth = await Provider.of<Auth>(context, listen: false).signInUsingEmail(
//              email: email.trim(), password: password.trim());
//          if (auth == true) {
//            Toast.show(
//                "successfully Sign Up", context, duration: Toast.LENGTH_SHORT,
//                gravity: Toast.BOTTOM);
//            Navigator.of(context).pushReplacement(
//                MaterialPageRoute(builder: (context) => HomeScreen()));
//          }
//        } on HttpException catch (error) {
//          setState(() {
//            _isSignInSuccessful = false;
//          });
//          switch (error.toString()) {
//            case "ERROR_INVALID_EMAIL":
//              errorMessage = "Your email address appears to be malformed.";
//              break;
//            case "ERROR_WRONG_PASSWORD":
//              errorMessage = "Your password is wrong.";
//              break;
//            case "ERROR_USER_NOT_FOUND":
//              errorMessage = "User with this email doesn't exist.";
//              break;
//            case "ERROR_USER_DISABLED":
//              errorMessage = "User with this email has been disabled.";
//              break;
//            case "ERROR_TOO_MANY_REQUESTS":
//              errorMessage = "Too many requests. Try again later.";
//              break;
//            case "ERROR_OPERATION_NOT_ALLOWED":
//              errorMessage = "Signing in with Email and Password is not enabled.";
//              break;
//            default:
//              errorMessage = "An undefined Error happened.";
//          }
//          _showErrorDialog(errorMessage);
//        } catch (error) {
//          setState(() {
//            _isSignInSuccessful = false;
//          });
//          const errorMessage =
//              'Could not authenticate you. Please try again later.';
//          _showErrorDialog(errorMessage);
//        }
//      }
//    }
  }

//  getLocation() {
//    try {
//     // Provider.of<Auth>(context, listen: false).getLocation();
//    } on HttpException catch (error) {
//      switch (error.toString()) {
//        case "PERMISSION_DENIED":
//          errorMessage = "Please enable Your Location";
//          break;
//        default:
//          errorMessage = "An undefined Error happened.";
//      }
//      _showErrorDialogLocation(errorMessage);
//    } catch (error) {
//      const errorMessage = 'Could not get your location. Please try again.';
//      _showErrorDialogLocation(errorMessage);
//    }
//  }
//  void _showErrorDialogLocation(String message) {
//    showDialog(
//      context: context,
//      builder: (ctx) => AlertDialog(
//        title: Text('An Error Occurred!'),
//        content: Text(message),
//        actions: <Widget>[
//          FlatButton(
//            child: Text('Enable Now'),
//            onPressed: () {
//              getLocation();
//              Navigator.of(ctx).pop();
//            },
//          ),
//          FlatButton(
//            child: Text('Cancel'),
//            onPressed: () {
//              Navigator.of(ctx).pop();
//            },
//          )
//        ],
//      ),
//    );
//  }
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
//                        bool x = await Provider.of<Auth>(context, listen: false).signInUsingFBorG('G');
//                        if(x==false){
//                          Toast.show("Please try again!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
//                          setState(() {
//                            _isSignInUsingGoogleSuccessful=false;
//                          });
//                        }else{
//                          Toast.show("successfully Sign Up", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
//                          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomeScreen()));
//                          //getLocation();
//                        }
//
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
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
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
                          Toast.show("Please try again!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                          setState(() {
                            _isSignInUsingGoogleSuccessful=false;
                          });
                        }else{
                          Toast.show("successfully Sign Up", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                          //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomeScreen()));
                          //getLocation();
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
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                               Toast.show("Please try again!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                               setState(() {
                                 _isSignInUsingFBSuccessful=false;
                               });
                             }else{
                               Toast.show("successfully Sign Up", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                               //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomeScreen()));
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
                                   style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold),
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
                              TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            InkWell(
                              onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>RegisterUsingPhone()));
                              },
                              child: Text(
                                translator.currentLanguage == "en"
                                    ? 'Register!':'!سجل',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    decoration: TextDecoration.underline),
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