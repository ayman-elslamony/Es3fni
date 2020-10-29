import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/verify_code.dart';
import 'package:helpme/screens/sign_in_and_up/sign_in/sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class RegisterUsingPhone extends StatefulWidget {
  @override
  _RegisterUsingPhoneState createState() => _RegisterUsingPhoneState();
}

class _RegisterUsingPhoneState extends State<RegisterUsingPhone> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode focusNode=FocusNode();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  PhoneNumber phoneNumber;
Auth _auth;
@override
  void initState() {
  _auth =Provider.of<Auth>(context,listen: false);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
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
                    Image.asset('assets/Logo.png',
                        fit: BoxFit.fill,
                        width: infoWidget.orientation ==
                            Orientation.landscape
                            ? infoWidget.screenWidth * 0.2
                            : infoWidget.screenWidth * 0.28),
                    SizedBox(
                      height: infoWidget.screenWidth * 0.2,
                    ),
                    Text(translator.currentLanguage == "en" ?'Registration':'التسجيل',
                      style: infoWidget.title,),
                    SizedBox(height: 5,),
                    Text(translator.currentLanguage == "en" ?'Enter Your Mobile Number To Recieive A Verification Code':'ادخل رقم الهاتف لتستقبل كود التحقق',
                      style: infoWidget.subTitle,),
                    SizedBox(
                      height: 30,
                    ),
                    Material(
                      shadowColor: Colors.indigoAccent,
                      elevation: 1.0,
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: formKey,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    phoneNumber= number;
                                  },
                                  focusNode: focusNode,
                                  ignoreBlank: true,
                                  autoValidate: false,
                                  selectorTextStyle: TextStyle(color: Colors.black),
                                  initialValue: number,
                                  inputDecoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(color: Colors.indigo),
                                      ),
                                      errorStyle: TextStyle(color: Colors.indigo)
                                  ),
                                  textFieldController: controller,
                                  inputBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.indigo),
                                  ),
                                  hintText: translator.currentLanguage == "en" ?'phone number':'رقم الهاتف',
                                ),
                                SizedBox(height: 30,),
                                RaisedButton(
                                  onPressed: () {
                                    focusNode.unfocus();
                                    formKey.currentState.validate();
                                    if(controller.text.trim().length ==12) {
                                      formKey.currentState.save();
                                      _auth.signInUsingPhone(
                                          infoWidget: infoWidget,
                                          context: context,
                                          phone: phoneNumber
                                      );
                                    }else{
                                      Toast.show(translator.currentLanguage == "en" ?'invalid phone number':'الرقم غير صحيح', context);
                                    }
                                  },
                                  color: Colors.indigo,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 50),
                                    child: Text(
                                      translator.currentLanguage == "en" ?'Get Code':'الحصول على الكود',
                                      style: infoWidget.titleButton,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
                        children: <Widget>[
                          Text(
                            translator.currentLanguage == "en" ?'I have Account ':'امتلك حساب ',
                            style:
                            TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignIn()));
                            },
                            child: Text(
                              translator.currentLanguage == "en" ?'Sign In!':'تسجيل الدخول',
                              style: TextStyle(
                                  color: Colors.indigo,
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
        );
      },
    );
  }
}
