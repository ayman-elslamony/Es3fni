import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../home_screen.dart';

class VerifyCode extends StatefulWidget {
  final String phoneNumber;
final Function function;
  VerifyCode({this.phoneNumber,this.function});

  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  int _timerValue = 59;
  Stream<int> _periodicStream =
      Stream.periodic(Duration(milliseconds: 1000), (i) => i);
  int _previousStreamValue = 0;
  bool loadingStream = false;
  String _code;
Auth _auth;
  @override
  void initState() {
    _auth = Provider.of<Auth>(context,listen:false);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: infoWidget.screenWidth * 0.16,
                        ),
//                        Image.asset('assets/Logo.png',
//                            fit: BoxFit.fill,
//                            width:
//                            infoWidget.orientation == Orientation.landscape
//                                ? infoWidget.localWidth * 0.2
//                                : infoWidget.localWidth * 0.28),
//                        SizedBox(
//                          height: infoWidget.screenWidth * 0.2,
//                        ),
                        Text(
                          translator.currentLanguage == "en"
                              ? 'Verification'
                              : 'التحقق',
                          style: infoWidget.title,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          translator.currentLanguage == "en"
                              ? 'Enter A 4 Digit Number That Was Sent To ${widget.phoneNumber}'
                              : '${widget.phoneNumber}ادخل الكود المرسل الى الرقم ',
                          style: infoWidget.subTitle,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Material(
                                shadowColor: Colors.indigoAccent,
                                elevation: 1.0,
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                                type: MaterialType.card,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          width: infoWidget.screenWidth * 0.80,
                                          child: Center(
                                            child: VerificationCode(
                                              textStyle: infoWidget.title
                                                  .copyWith(
                                                  color: Colors.indigo),
                                              underlineColor: Colors.indigo,
                                              itemSize: 40,
                                              keyboardType:
                                              TextInputType.number,
                                              length: 6,
                                              clearAll: Padding(
                                                  padding:
                                                  const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    'clear all',
                                                    style: infoWidget.subTitle
                                                        .copyWith(
                                                        color: Colors
                                                            .indigo[300]),
                                                  )),
                                              onCompleted: (String value) {
                                                setState(() {
                                                  _code = value;
                                                });
                                              },
                                              onEditing: (_) {},
                                              autofocus: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            print(_code);
                                            if (_code == null) {
                                              Toast.show(
                                                  translator.currentLanguage ==
                                                      "en"
                                                      ? 'enter code'
                                                      : 'ادخل الكود',
                                                  context);
                                            } else if (_code.length != 6) {
                                              Toast.show(
                                                  translator.currentLanguage ==
                                                      "en"
                                                      ? 'invalid code'
                                                      : 'الكود غير صحيح',
                                                  context);
                                            } else {
                                              print('qqqqqqqqqq');
                                              widget.function(_code);
                                            }
                                          },
                                          color: Colors.indigo,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 50),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Verify Code'
                                                  : 'تحقق من الكود',
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
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () async{
                            if (loadingStream == false) {
                              setState(() {
                                loadingStream = true;
                              });
                              _timerValue = 59;
                              _periodicStream = Stream.periodic(
                                  Duration(milliseconds: 1000), (i) => i);
                              _previousStreamValue = 0;

                              String x=await  _auth.signInUsingPhone(
                                  infoWidget: infoWidget,
                                  context: context,
                                  phone: widget.phoneNumber
                              );
                              if(x == 'verifysccuess'){
                                Toast.show(translator.currentLanguage == "en"
                                    ? "successfully Sign In":'نجح تسجيل الدخول', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomePage()));
                              }else{
                                Toast.show(translator.currentLanguage == "en"
                                    ? "$x":'$x', context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                              }
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: translator.currentLanguage == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            children: <Widget>[
                              Text(
                                  translator.currentLanguage == "en"
                                      ? 'Re-send Code in '
                                      : ' اعاده ارسال الكود ',
                                  style: infoWidget.subTitle
                                      .copyWith(color: Colors.indigo)),
                              loadingStream
                                  ? StreamBuilder(
                                stream: this._periodicStream,
                                builder: (context,
                                    AsyncSnapshot<int> snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data !=
                                        _previousStreamValue) {
                                      if (this._timerValue > 0) {
                                        this._timerValue--;
                                      }
                                    }
                                    if (_timerValue == 0) {
                                      loadingStream = false;
                                    }
                                  }
                                  return Text(
                                    ' 0:$_timerValue ',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: infoWidget.subTitle
                                        .copyWith(color: Colors.indigo),
                                  );
                                },
                              )
                                  : SizedBox(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: BackButton(
                    color: Colors.indigo,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  left: 4.0,
                  top: 6.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
