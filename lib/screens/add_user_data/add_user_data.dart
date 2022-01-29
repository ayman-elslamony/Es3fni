import 'dart:io';


import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/shared_widget/map.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:helpme/screens/sign_in_and_up/sign_in/sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../main_screen.dart';

class AddUserData extends StatefulWidget {
  @override
  _AddUserDataState createState() => _AddUserDataState();
}
class _AddUserDataState extends State<AddUserData> {
  GlobalKey<FormState> _newAccountKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  FocusNode focusNode = FocusNode();
  FocusNode locationFocusNode = FocusNode();
  FocusNode anotherInfoFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode idFocusNode = FocusNode();
  final TextEditingController controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  bool _isLoading = false;
  int currentStep = 0;
  bool complete = false;
  bool _isEditLocationEnable = true;
  bool _selectUserLocationFromMap = false;
  bool _isGenderSelected = false;
  bool enablePicture = false;
  bool enablePictureID = false;
  List<bool> values = List.filled(7, false);
  TextEditingController _locationTextEditingController =
  TextEditingController();
  String lat;
  String lng;
  File _imageFileForPersonalImage;
  File _imageFileForId;
  List<String> _genderList = [];
  Map<String, dynamic> _userData = {
    'name': '',
    'Phone number': '',
    'gender': '',
    'National Id': '',
    'Birth Date': translator.activeLanguageCode == "en"
        ?"Date":'التاريخ',
    'aboutYou': '',
    'UrlImgForUser': '',
    'UrlImgForId': '',
    'Location': '',
  };

  final ImagePicker _picker = ImagePicker();
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
    print('_auth.userData.phoneNumber');//print(_auth.userData.phoneNumber);
    _genderList = translator.activeLanguageCode =='en'?['Male', 'Female']:['ذكر', 'انثى'];
    if(_auth.userData !=null) {
      nameController.text = _auth.userData.name;
      _userData['name'] = _auth.userData.name;
      if(_auth.userData.imgUrl !=''){
        _userData['UrlImgForUser'] =_auth.userData.imgUrl;
        enablePicture = true;
      }
    }
    if(_auth.phoneNumber !=null){
      _userData['Phone number']=_auth.phoneNumber.phoneNumber;
      number = _auth.phoneNumber;
    }
    if(_auth.userData.phoneNumber.contains('+20')){
        String phoneNumber = _auth.userData.phoneNumber.replaceAll('+20', '');
        String dialCode = '+20';
        number = PhoneNumber(isoCode: 'EG',dialCode: dialCode,phoneNumber: phoneNumber);
    }


  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }
  Widget _createTextForm(
      {String labelText,
        FocusNode currentFocusNode,
        FocusNode nextFocusNode,
        TextInputType textInputType = TextInputType.text,
        bool isSuffixIcon = false,
        Function validator,
        IconData suffixIcon,
        bool isStopped = false,
        bool isEnable = true,
        TextEditingController controller}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      height: 80,
      child: TextFormField(
        controller: controller,
        autofocus: false,
        textInputAction:
        isStopped ? TextInputAction.done : TextInputAction.next,
        focusNode: currentFocusNode == null ? null : currentFocusNode,
        enabled: isEnable,
        decoration: InputDecoration(
          suffixIcon: Icon(
            suffixIcon,
            size: 20,
            color: Colors.indigo,
          ),
          labelText: translator.activeLanguageCode == "en"
              ? 'Name'
              : 'الاسم',
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
        ),
        keyboardType: textInputType,
// ignore: missing_return
        validator: validator,
        onSaved: (value) {
          _userData['$labelText'] = value.trim();
          if (currentFocusNode != null) {
            currentFocusNode.unfocus();
          }
          if (isStopped == false) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        onChanged: (value) {
          _userData['$labelText'] = value.trim();
        },
        onFieldSubmitted: (_) {
          if (currentFocusNode != null) {
            currentFocusNode.unfocus();
          }
          if (isStopped == false) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  Future<String> _getLocation() async {
    await Geolocator.requestPermission();
    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    lat = position.latitude
    .toString();
    lng=  position.longitude.toString();
    var addresses =
    await placemarkFromCoordinates(position.latitude, position.longitude);
     return addresses.first.street;
  }

  void _getUserLocation() async {
    _userData['Location'] = await _getLocation();
    setState(() {
      _locationTextEditingController.text = _userData['Location'];
      _isEditLocationEnable = true;
      _selectUserLocationFromMap = !_selectUserLocationFromMap;
    });
    Navigator.of(context).pop();
  }

  void selectLocationFromTheMap(String address, double lat, double long) {
    setState(() {
      _locationTextEditingController.text = address;
    });
    _userData['Location'] = address;
    this.lat = lat
        .toString();
    this.lng=  long.toString();
  }

  void selectUserLocationType() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Text(
          translator.activeLanguageCode == "en" ? 'Location' : 'الموقع',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * 0.038
                  : MediaQuery.of(context).size.width * 0.024,
              color: Colors.indigo,
              fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    onPressed: _getUserLocation,
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        translator.activeLanguageCode == "en"
                            ? 'Get current Location'
                            : 'الموقع الحالى',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (ctx) => GetUserLocation(
                            getAddress: selectLocationFromTheMap,
                          )));
                      setState(() {
                        _isEditLocationEnable = true;
                        _selectUserLocationFromMap =
                        !_selectUserLocationFromMap;
                      });
                    },
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        translator.activeLanguageCode == "en"
                            ? 'Select Location from Map'
                            : 'اختر موقع من الخريطه',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child:
            Text(translator.activeLanguageCode == "en" ? 'Cancel' : 'الغاء'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source,String type) async {
    await _picker
        .getImage(source: source, maxWidth: 400.0)
        .then((PickedFile image) {
      if (image != null) {
        File x = File(image.path);
        if(type=='ID') {
          _userData['UrlImgForId'] = x;
          setState(() {
            _imageFileForId = x;
            enablePictureID = true;
          });
        }else{
          _userData['UrlImgForUser'] = x;
          setState(() {
            _imageFileForPersonalImage = x;
            enablePicture = true;
          });
        }
      }
      Navigator.pop(context);
    });
  }

  void _openImagePicker({String type='ID'}) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.height*0.16:MediaQuery.of(context).size.height*0.28,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                  translator.activeLanguageCode == "en"
                      ? 'Pick an Image'
                      : 'التقط صوره',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                          Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.04
                          : MediaQuery.of(context).size.width * 0.03,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: MediaQuery.of(context).orientation ==
                          Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.065
                          : MediaQuery.of(context).size.width * 0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.indigo,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      translator.activeLanguageCode == "en"
                          ? 'Use Camera'
                          : 'استخدم الكاميرا',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                              ? MediaQuery.of(context).size.width * 0.035
                              : MediaQuery.of(context).size.width * 0.024,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getImage(ImageSource.camera,type);
                      // Navigator.of(context).pop();
                    },
                  ),
                  FlatButton.icon(
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: MediaQuery.of(context).orientation ==
                          Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.065
                          : MediaQuery.of(context).size.width * 0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.indigo,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      translator.activeLanguageCode == "en"
                          ? 'Use Gallery'
                          : 'استخدم المعرض',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                              ? MediaQuery.of(context).size.width * 0.035
                              : MediaQuery.of(context).size.width * 0.024,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getImage(ImageSource.gallery,type);
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ]),
          );
        });
  }

  verifyUserData() async {
      setState(() {
        _isLoading = true;
      });
      bool isVerify = true;
      if(_auth.getUserType !='nurse'){
        isVerify =await Provider.of<Auth>(context, listen: false).verifyUniqueId(id: _userData['National Id']);
      }
      if(isVerify){
      try {
        print('dgfdsgsd');
        bool isScuess =await Provider.of<Auth>(context, listen: false)
            .addUserData(
          name: _userData['name'].toString(),
          lat: lat,
          lng: lng,
          pictureId: _userData['UrlImgForId']==''?null:_userData['UrlImgForId'],
          nationalId: _userData['National Id'],
          phoneNumber: _userData['Phone number'].toString(),
          birthDate: _userData['Birth Date'].toString(),
          gender: _userData['gender'],
         picture: _userData['UrlImgForUser']==''?null:_userData['UrlImgForUser'],
          aboutYou: _userData['aboutYou'].toString(),
            location:_userData['Location'],
        );
        print('isScuessisScuess$isScuess');
        if (isScuess) {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
              translator.activeLanguageCode == "en"
                  ? "Welcome ${_auth.userData.name}"
                  : ' مرحبا ${_auth.userData.name} ',
              context,
              gravity: Toast.BOTTOM,);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder:(context)=>HomeScreen()));
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(translator.activeLanguageCode == "en"
              ?"Please try again":'من فضلك حاول مره اخرى', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        Toast.show(translator.activeLanguageCode == "en"
            ?"Please try again":'من فضلك حاول مره اخرى', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
      }else{
        setState(() {
          _isLoading = false;
        });
        Toast.show(
            translator.activeLanguageCode == "en"
                ? "National Id is used by another account"
                : 'الرقم القومى مستخدم بواسطه حساب اخر',
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM);
      }
    }

  _incrementStep() {
    currentStep + 1 == 1
        ? setState(() => complete = true)
        : goTo(currentStep + 1);
  }

  nextStep() async {
    print(currentStep);
      if (_newAccountKey.currentState.validate()) {
        _newAccountKey.currentState.save();
        _incrementStep();
      }

    if (currentStep == 0) {
      if(_auth.getUserType == 'nurse') {
        if (_userData['Birth Date'] == '' ||
            _userData['gender'] == '' ||
            _userData['Location'] == ''
        ) {
          Toast.show(
              translator.activeLanguageCode == "en"
                  ? "Please Complete data"
                  : 'من فضلك اكمل البيانات',
              context,
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.BOTTOM);
        } else {
          verifyUserData();
        }
      }else{
        if (_userData['Birth Date'] == '' ||
            _userData['gender'] == '' ||
            _userData['Location'] == ''||
            _userData['UrlImgForUser'] == ''||_userData['UrlImgForId'] == ''
        ) {
          Toast.show(
              translator.activeLanguageCode == "en"
                  ? "Please Complete data"
                  : 'من فضلك اكمل البيانات',
              context,
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.BOTTOM);
        } else {
          verifyUserData();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return InfoWidget(
      builder: (context, infoWidget) => Directionality(
        textDirection: translator.activeLanguageCode == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          key: _key,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              translator.activeLanguageCode == "en"
                  ? 'Add Your information'
                  : 'أدخل معلوماتك',
              style: infoWidget.titleButton,
            ),
            leading: SizedBox(),
            actions: <Widget>[
              InkWell(
                onTap: () async {
        await Provider.of<Auth>(context, listen: false)
            .logout();
        if(Navigator.canPop(context)){
          Navigator.of(context).pop(true);
        }else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) =>SignIn()));
        }
        },
                child: Row(
                  children: <Widget>[
                    Text(translator.activeLanguageCode=='en'?'  Log out ':'تسجيل الخروج   ',style: infoWidget.subTitle.copyWith(color: Colors.white),),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                    ),
                  )
                      : Stepper(
                    controlsBuilder: (BuildContext context, control) {
                      return Row(
                        children: <Widget>[
                          FlatButton(
                            color: Colors.indigo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed: control.onStepContinue,
                            child: Text(translator.activeLanguageCode=='en'?'Continue':'التالى',style: infoWidget.subTitle.copyWith(color: Colors.white)),
                          ),
                          SizedBox(width: 8,)
                          ,FlatButton(
                            color: Colors.indigo,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed: control.onStepCancel,
                            child:  Text(translator.activeLanguageCode=='en'?'Cancel':'الغاء',style: infoWidget.subTitle.copyWith(color: Colors.white),),
                          ),
                        ],
                      );
                    },
                    steps: [
                      Step(
                        title: Text(translator.activeLanguageCode == "en"
                            ? 'Personal Information'
                            : 'المعلومات الشخصيه',style: infoWidget.subTitle.copyWith(color: Color(0xff484848)),),
                        isActive: true,
                        state: StepState.indexed,
                        content: Form(
                          key: _newAccountKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _createTextForm(
                                  labelText: 'name',
                                  controller: nameController,
                                  currentFocusNode: nameFocusNode,
                                  nextFocusNode: idFocusNode,
                                  // ignore: missing_return
                                  validator: (String val) {
                                    if (val.trim().isEmpty || val.trim().length < 2) {
                                      return translator.activeLanguageCode == "en"
                                          ? 'Please enter your name'
                                          : 'من فضلك ادخل اسمك';
                                    }
                                    if (val.trim().length < 2) {
                                      return translator.activeLanguageCode == "en"
                                          ? 'Invalid Name'
                                          : 'الاسم خطاء';
                                    }
                                  }),
                            _auth.getUserType !='nurse'?
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 7.0),
                                height: 80,
                                child: TextFormField(
                                  autofocus: false,
                                  focusNode: idFocusNode,
                                  controller: nationalIdController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: translator.activeLanguageCode == "en"
                                        ? "National Id"
                                        : 'الرقم القومى',
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
                                  ),
                                  keyboardType: TextInputType.phone,
// ignore: missing_return
                                  validator: (String value) {
                                    if (value.trim().isEmpty) {
                                      return translator.activeLanguageCode == "en"
                                          ? "Please enter National Id!"
                                          : 'من فضلك ادخل الرقم القومى';
                                    }
                                    if (value.trim().length != 14) {
                                      return translator.activeLanguageCode == "en"
                                          ? "Invalid national id!"
                                          : 'الرقم خطاء';
                                    }
                                  },
                                  onChanged: (value) {
                                    _userData['National Id'] = value.trim();
                                  },
                                  onSaved: (value) {
                                    _userData['National Id'] = value.trim();
//                    _phoneNumberNode.unfocus();
                                  },
                                  onFieldSubmitted: (_) {
                    idFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(locationFocusNode);
                                  },
                                ),
                              ):SizedBox(),

                              Container(
                                padding: EdgeInsets.symmetric(vertical: 0.0),
                                height: 80,
                                child: TextFormField(
                                  autofocus: false,
                                  focusNode: locationFocusNode,
                                  style: TextStyle(fontSize: 15),
                                  controller: _locationTextEditingController,
                                  textInputAction: TextInputAction.done,
                                  enabled: _isEditLocationEnable,
                                  decoration: InputDecoration(
                                    suffixIcon: InkWell(
                                      onTap: selectUserLocationType,
                                      child: Icon(
                                        Icons.my_location,
                                        size: 20,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    labelText: translator.activeLanguageCode == "en"
                                        ? 'Location'
                                        : 'الموقع',
                                    focusedBorder: OutlineInputBorder(
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
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      borderSide: BorderSide(color: Colors.indigo),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                      borderSide: BorderSide(color: Colors.indigo),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                onChanged: (val){
                                    _userData['Location']=val.trim;
                                },
                                  onFieldSubmitted: (_) {
                                    locationFocusNode.unfocus();
                                    FocusScope.of(context).requestFocus(focusNode);
                                  },
                                ),
                              ),
                              InternationalPhoneNumberInput(
                                onInputChanged: (PhoneNumber number) {
                                  _userData['Phone number']=number.toString();
                                },
                                onSubmit: (){
                                  focusNode.unfocus();
                                },
                                ignoreBlank: true,
                                autoValidateMode: AutovalidateMode.always,
                                focusNode: focusNode,
                                isEnabled: _auth.phoneNumber !=null?false:true,
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
                                hintText: translator.activeLanguageCode == "en" ?'phone number':'رقم الهاتف',
                              ),
                              _auth.getUserType =='nurse'
                                  ? SizedBox(height:12): SizedBox(),
                            _auth.getUserType =='nurse'
                                ? Container(
                        height: 90,
                        padding: EdgeInsets.symmetric(
                            vertical: 7.0),
        child: TextFormField(
          autofocus: false,
          focusNode: anotherInfoFocusNode,
          textInputAction:
          TextInputAction.newline,
          decoration: InputDecoration(
            labelText:
            translator.activeLanguageCode ==
                "en"
                ? "Another Info"
                : 'معلومات اخرى',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)),
              borderSide: BorderSide(
                color: Colors.indigo,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)),
              borderSide: BorderSide(
                color: Colors.indigo,
              ),
            ),
            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)),
              borderSide: BorderSide(
                color: Colors.indigo,
              ),
            ),
            disabledBorder:
            OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)),
              borderSide: BorderSide(
                color: Colors.indigo,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0)),
              borderSide: BorderSide(
                  color: Colors.indigo),
            ),
          ),
          keyboardType: TextInputType.text,
          onChanged: (value) {
            _userData['aboutYou'] =
                value.trim();
          },
          maxLines: 5,
          minLines: 2,
        ),
      )
            : SizedBox(),
                              _auth.getUserType =='nurse'
                                  ?SizedBox(height: 4,):SizedBox(height: 18),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                      child: Text(
                                        translator.activeLanguageCode == "en" ? 'Birth Date:  ' : 'تاريخ الميلاد:  ',
                                          style: infoWidget.subTitle.copyWith(color: Color(0xff484848))
                                      ),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        DatePicker.showDatePicker(context,
                                            showTitleActions: true,
                                            theme: DatePickerTheme(
                                              itemStyle: TextStyle(color: Colors.indigo),
                                              backgroundColor: Colors.white,
                                              headerColor: Colors.white,
                                              doneStyle:
                                              TextStyle(color: Colors.indigoAccent),
                                              cancelStyle:
                                              TextStyle(color: Colors.black87),
                                            ),
                                            maxTime: DateTime(2080, 6, 7),
                                            onChanged: (_) {}, onConfirm: (date) {
                                              print('confirm $date');
                                              setState(() {
                                                _userData['Birth Date'] =
                                                '${date.year}-${date.month}-${date.day}';
                                              });
                                            },
                                            currentTime: DateTime.now(),
                                            locale: translator.activeLanguageCode == "en"
                                                ? LocaleType.en
                                                : LocaleType.ar);
                                      },
                                      color: Colors.indigo,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Text(
                                        translator.activeLanguageCode == "en"
                                            ? '${_userData['Birth Date']}'
                                            : '${_userData['Birth Date']}',
                                          style: infoWidget.subTitle.copyWith(color: Colors.white)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                      child: Text(
                                        translator.activeLanguageCode == "en"
                                            ? 'Gender:'
                                            : 'النوع:',style: infoWidget.subTitle.copyWith(color: Color(0xff484848))
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Material(
                                        shadowColor: Colors.blueAccent,
                                        elevation: 2.0,
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        type: MaterialType.card,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(left: 8.0, right: 8.0),
                                              child: Text(
                                                  _isGenderSelected == false
                                                      ? translator.activeLanguageCode == "en"
                                                      ? 'gender'
                                                      : 'النوع'
                                                      : _userData['gender'],style: infoWidget.subTitle.copyWith(color: Color(0xff484848))),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 35,
                                              child: PopupMenuButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                    side: BorderSide(color: Colors.indigo)
                                                ),
                                                initialValue: translator.activeLanguageCode == "en"
                                                    ? 'Male'
                                                    : 'ذكر',
                                                tooltip: 'Select Gender',
                                                itemBuilder: (ctx) => _genderList
                                                    .map((String val) => PopupMenuItem<String>(
                                                  value: val,
                                                  child: Text(val.toString()),
                                                ))
                                                    .toList(),
                                                onSelected: (val) {
                                                  setState(() {
                                                    _userData['gender'] = val.trim();
                                                    _isGenderSelected = true;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              _auth.getUserType!='nurse'?Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: Text(
                                          translator.activeLanguageCode == "en"
                                              ? 'A photo of the ID from the front :'
                                              : 'صوره البطاقه الشخصيه من الامام:',
                                            style: infoWidget.subTitle.copyWith(color: Color(0xff484848)),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    enablePictureID
                                        ? SizedBox()
                                        : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: InkWell(
                                            onTap: () {
                                              _openImagePicker();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.indigo,
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: Center(
                                                child: Text(
                                                  translator.activeLanguageCode == "en"
                                                      ? " Select Image "
                                                      : ' اختر صوره ',
                                                    style: infoWidget.subTitle.copyWith(color: Colors.white)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ):SizedBox(),
                              enablePictureID
                                  ? Container(
                                width: double.infinity,
                                height: 200,
                                child: Stack(
                                  children: <Widget>[
                                    ClipRRect(
                                      //backgroundColor: Colors.white,
                                      //backgroundImage:
                                      borderRadius: BorderRadius.circular(10),
                                      child: InkWell(
                                        onTap: (){
                                          if(_imageFileForId !=null) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) =>
                                                    ShowImage(
                                                      title: translator.activeLanguageCode ==
                                                          "en" ? 'Picture for national id'
                                                          : 'صوره البطاقه',
                                                      imageFile: _imageFileForId,
                                                    )));
                                          }
                                        },
                                        child: Image.file(
                                          _imageFileForId,
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: 200,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        top: 3.0,
                                        right: 3.0,
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.clear,
                                              color: Colors.indigo,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _userData['UrlImgForId'] = '';
                                                _imageFileForId = null;
                                                enablePictureID = false;
                                              });
                                            }))
                                  ],
                                ),
                              )
                                  : SizedBox(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: Text(
                                          translator.activeLanguageCode == "en"
                                              ? 'Add picture:'
                                              : 'اضافه صوره شخصيه:'
                                            ,style: infoWidget.subTitle.copyWith(color: Color(0xff484848))
                                          ,maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    enablePicture
                                        ? SizedBox()
                                        : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: InkWell(
                                            onTap: () {
                                              _openImagePicker(type: 'w');
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.indigo,
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: Center(
                                                child: Text(
                                                  translator.activeLanguageCode == "en"
                                                      ? " Select Image "
                                                      : ' اختر صوره ',
                                                    style: infoWidget.subTitle.copyWith(color: Colors.white)
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              enablePicture
                                  ? InkWell(
                                onTap: (){
                                  if(_userData['UrlImgForUser'].runtimeType == String) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            ShowImage(
                                              title: translator.activeLanguageCode ==
                                                  "en" ? 'personal picture'
                                                  : 'الصوره الشخصيه',
                                              imgUrl:_userData['UrlImgForUser'],
                                              isImgUrlAsset: false,
                                            )));
                                  }else{
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            ShowImage(
                                              title: translator.activeLanguageCode ==
                                                  "en" ? 'personal picture'
                                                  : 'الصوره الشخصيه',
                                              imageFile: _imageFileForPersonalImage,
                                            )));
                                  }
                                },
                                    child: Container(
                                width: double.infinity,
                                height: 200,
                                child: Stack(
                                    children: <Widget>[
                                      ClipRRect(
                                        //backgroundColor: Colors.white,
                                        //backgroundImage:
                                        borderRadius: BorderRadius.circular(10),
                                        child: _userData['UrlImgForUser'].runtimeType == String?Image.network(
                                            _userData['UrlImgForUser'],
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: 200,
                                        ):Image.file(
                                          _imageFileForPersonalImage,
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: 200,
                                        ),
                                      ),
                                      Positioned(
                                          top: 3.0,
                                          right: 3.0,
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.indigo,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _userData['UrlImgForUser'] = '';
                                                  _imageFileForPersonalImage = null;
                                                  enablePicture = false;
                                                });
                                              }))
                                    ],
                                ),
                              ),
                                  )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                    currentStep: currentStep,
                    onStepContinue: nextStep,
                    onStepTapped: (step) => goTo(step),
                    onStepCancel: cancel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
