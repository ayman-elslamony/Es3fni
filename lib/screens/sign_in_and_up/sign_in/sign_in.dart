import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/add_user_data/add_user_data.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/register_using_phone.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/verify_code.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../../models/http_exception.dart';
import '../../main_screen.dart';
import 'dart:convert';
import 'dart:io';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email;
  String password;
  final FocusNode _passwordNode = FocusNode();
  bool _showPassword = false;
  bool _isSignInSuccessful = false;
  Auth _auth;
  FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  PhoneNumber phoneNumber;
  String errorMessage;
  bool _isSignInUsingFBSuccessful = false;
  bool _isSignInUsingGoogleSuccessful = false;
  bool _isSignInUsingPhoneSuccessful = false;
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

  Future<void> _submitForm({BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isSignInSuccessful = true;
      });
      try {
        bool auth = await Provider.of<Auth>(context, listen: false)
            .signInUsingEmailForNurse(
                email: email.trim(),
                password: password.trim(),
                context: context);
        if (auth == true) {
          Toast.show("successfully Sign In", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        setState(() {
          _isSignInSuccessful = false;
        });
      } on HttpException catch (error) {
        setState(() {
          _isSignInSuccessful = false;
        });
        switch (error.toString()) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        _showErrorDialog(errorMessage);
      } catch (error) {
        setState(() {
          _isSignInSuccessful = false;
        });
        const errorMessage =
            'Could not authenticate you. Please try again later.';
        _showErrorDialog(errorMessage);
      }
    }
  }

  @override
  void initState() {
    _auth = Provider.of<Auth>(context, listen: false);
    getPhoneNumber();
    super.initState();
  }

  getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('savePhoneNumber');
    if (prefs.containsKey('savePhoneNumber')) {
      final phoneData = await json.decode(prefs.getString('savePhoneNumber'))
          as Map<String, Object>;
      _isSignInUsingPhoneSuccessful = true;
      phoneNumber = PhoneNumber(
        phoneNumber: phoneData['PhoneNumber'],
        dialCode: phoneData['dialCode'],
        isoCode: phoneData['isoCode'],
      );
      number = PhoneNumber(
        phoneNumber: phoneData['PhoneNumber'],
        dialCode: phoneData['dialCode'],
        isoCode: phoneData['isoCode'],
      );
      print(phoneData['PhoneNumber']);
      controller.text = phoneData['PhoneNumber'].toString();
     setState(() {

     });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
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
                          width: infoWidget.orientation == Orientation.landscape
                              ? infoWidget.localWidth * 0.2
                              : infoWidget.localWidth * 0.28),
                      SizedBox(
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          autofocus: false,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.indigo,
                          decoration: InputDecoration(
                            labelText: translator.currentLanguage == "en"
                                ? 'Email'
                                : 'البريد الالكترونى',
                            errorStyle: TextStyle(color: Colors.indigo),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          // ignore: missing_return
                          validator: (val) {
                            if (val.isEmpty || !val.contains('@')) {
                              return translator.currentLanguage == "en"
                                  ? 'InvalidEmail'
                                  : 'البريد الالكترونى غير صحيح';
                            }
                          },
                          onSaved: (val) {
                            email = val;
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordNode);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          focusNode: _passwordNode,
                          autofocus: false,
                          cursorColor: Colors.indigo,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _showPassword
                                      ? Colors.indigo
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                }),
                            labelText: translator.currentLanguage == "en"
                                ? 'Password'
                                : 'كلمه المرور',
                            errorStyle: TextStyle(color: Colors.indigo),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          // ignore: missing_return
                          validator: (val) {
                            if (val.trim().isEmpty) {
                              return translator.currentLanguage == "en"
                                  ? 'Invalid password'
                                  : 'كلمه المرور غير صحيحه';
                            }
                            if (val.trim().length < 4) {
                              return translator.currentLanguage == "en"
                                  ? 'Short password'
                                  : 'كلمه المرور ضعيفه';
                            }
                          },
                          onSaved: (val) {
                            password = val;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      _isSignInSuccessful
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(
                                  backgroundColor: Colors.indigo,
                                )
                              ],
                            )
                          : RaisedButton(
                              onPressed: () => _submitForm(context: context),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 50),
                                child: Text(
                                  translator.currentLanguage == "en"
                                      ? 'Login'
                                      : 'تسجيل الدخول',
                                  style: infoWidget.titleButton
                                      .copyWith(color: Colors.indigo),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.indigoAccent)),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      _isSignInUsingPhoneSuccessful
                          ? Material(
                              shadowColor: Colors.indigoAccent,
                              elevation: 1.0,
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              type: MaterialType.card,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: formKey,
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        InternationalPhoneNumberInput(
                                          onInputChanged: (PhoneNumber number) {
                                            phoneNumber = number;
                                          },
                                          focusNode: focusNode,
                                          ignoreBlank: false,
                                          autoValidate: false,
                                          selectorTextStyle:
                                              TextStyle(color: Colors.black),
                                          initialValue: number,
                                          textFieldController: controller,
                                          inputBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.indigo),
                                          ),
                                          hintText:
                                              translator.currentLanguage == "en"
                                                  ? 'phone number'
                                                  : 'رقم الهاتف',
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        RaisedButton(
                                          onPressed: () async {
                                            focusNode.unfocus();
                                            formKey.currentState.validate();
                                            if (controller.text.trim().length ==
                                                12) {
                                              formKey.currentState.save();
                                              print(phoneNumber);
                                              _auth.signInUsingPhone(
                                                  infoWidget: infoWidget,
                                                  context: context,
                                                  phone: phoneNumber);
                                            } else {
                                              Toast.show(
                                                  translator.currentLanguage ==
                                                          "en"
                                                      ? 'invalid phone number'
                                                      : 'الرقم غير صحيح',
                                                  context);
                                            }
                                          },
                                          color: Colors.indigo,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 50),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Get Code'
                                                  : 'الحصول على الكود',
                                              style: infoWidget.titleButton,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          : RaisedButton(
                              color: Colors.indigo,
                              onPressed: () {
                                setState(() {
                                  _isSignInUsingPhoneSuccessful = true;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    ImageIcon(
                                      AssetImage('assets/phone.png'),
                                      color: Colors.white,
                                    ),
                                    Expanded(
                                      child: Text(
                                        translator.currentLanguage == "en"
                                            ? 'Continue with Phone Number'
                                            : 'الدخول عن طريق الهاتف',
                                        textAlign: TextAlign.center,
                                        style: infoWidget.titleButton,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                              color: Colors.red,
                              onPressed: () async {
                                setState(() {
                                  _isSignInUsingGoogleSuccessful = true;
                                });
                                String x = await Provider.of<Auth>(context,
                                        listen: false)
                                    .signInUsingFBorG(
                                        type: 'G', context: context);
                                if (x == 'false') {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "Please try again!"
                                          : 'من فضلك حاول اخرى',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                  setState(() {
                                    _isSignInUsingGoogleSuccessful = false;
                                  });
                                } else if (x == 'GoToRegister') {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => AddUserData()));
                                } else {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "successfully Sign In"
                                          : 'نجح تسجيل الدخول',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()));
                                }
//
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _isSignInUsingGoogleSuccessful
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ImageIcon(
                                        AssetImage('assets/google.png'),
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                              color: Colors.blue[900],
                              onPressed: () async {
                                setState(() {
                                  _isSignInUsingFBSuccessful = true;
                                });
                                String x = await Provider.of<Auth>(context,
                                        listen: false)
                                    .signInUsingFBorG(
                                        type: 'FB', context: context);
                                if (x == 'false') {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "Please try again!"
                                          : 'من فضلك حاول اخرى',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                  setState(() {
                                    _isSignInUsingFBSuccessful = false;
                                  });
                                } else if (x == 'GoToRegister') {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => AddUserData()));
                                } else {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "successfully Sign In"
                                          : 'نجح تسجيل الدخول',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()));
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _isSignInUsingFBSuccessful
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ImageIcon(
                                        AssetImage(
                                          'assets/facebook.png',
                                        ),
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          textDirection: translator.currentLanguage == "en"
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              translator.currentLanguage == "en"
                                  ? 'Register with phone '
                                  : 'تسجيل برقم الهاتف ',
                              style: infoWidget.subTitle,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterUsingPhone()));
                              },
                              child: Text(
                                translator.currentLanguage == "en"
                                    ? 'Register!'
                                    : '!سجل',
                                style: infoWidget.subTitle
                                    .copyWith(color: Colors.indigo),
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
