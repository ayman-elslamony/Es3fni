import 'dart:io';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/shared_widget/map.dart';
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
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String phoneNumber;
  FocusNode focusNode=FocusNode();
  bool _isLoading = false;
  int currentStep = 0;
  bool complete = false;
  bool _isEditLocationEnable = true;
  bool _selectUserLocationFromMap = false;
  bool _isGenderSelected = false;
  bool _isAgeSelected = false;
  bool isSwitched = false;
  bool enableCoupon = false;
  bool enableScheduleTheService = false;
  bool enablePicture = false;
  bool _showWorkingDays = false;
  String _dateTime='';
  List<String> _selectedWorkingDays = List<String>();
  List<bool> _clicked = List<bool>.generate(7, (i) => false);
  List<String> _sortedWorkingDays = List<String>.generate(7, (i) => '');
  List<bool> values = List.filled(7, false);
  TextEditingController _locationTextEditingController =
  TextEditingController();
  File _imageFile;
  List<String> _genderList = ['Male', 'Female'];
  List<String> _ageList = List.generate(100, (index) {
    return '${1 + index}';
  });
  Map<String, dynamic> _userData = {
    'name': '',
    'Phone number': '',
    'gender': '',
    'National Id': '',
    'Birth Date': '',
    'UrlImg': '',
    'Location': '',
  };
  List<String> workingDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  List<String> visitTime=[];
  final FocusNode _phoneNumberNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  List<Step> steps = [];
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
    _genderList = ['ذكر', 'انثى'];
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
          labelText: translator.currentLanguage == "en"
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
    Position position =
    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);

    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    _userData['lat'] = position.latitude.toString();
    _userData['long'] = position.longitude.toString();
    return addresses.first.addressLine;
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
    _userData['lat'] = lat.toString();
    _userData['long'] = long.toString();
  }

  void selectUserLocationType() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Text(
          translator.currentLanguage == "en" ? 'Location' : 'الموقع',
          textAlign: TextAlign.center,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: _getUserLocation,
                  child: Material(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translator.currentLanguage == "en"
                              ? 'Get current Location'
                              : 'الموقع الحالى',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (ctx) => GetUserLocation(
                          getAddress: selectLocationFromTheMap,
                        )));
                    setState(() {
                      _isEditLocationEnable = true;
                      _selectUserLocationFromMap = !_selectUserLocationFromMap;
                    });
                  },
                  child: Material(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translator.currentLanguage == "en"
                              ? 'Select Location from Map'
                              : 'اختر موقع من الخريطه',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child:
            Text(translator.currentLanguage == "en" ? 'Cancel' : 'الغاء'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    await _picker
        .getImage(source: source, maxWidth: 400.0)
        .then((PickedFile image) {
      if (image != null) {
        File x = File(image.path);
        _userData['UrlImg'] = x;
        setState(() {
          _imageFile = x;
          enablePicture = true;
        });
      }
      Navigator.pop(context);
    });
  }

  void _openImagePicker() {
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
                  translator.currentLanguage == "en"
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
                      translator.currentLanguage == "en"
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
                      _getImage(ImageSource.camera);
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
                      translator.currentLanguage == "en"
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
                      _getImage(ImageSource.gallery);
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
    if (_userData['Patient name'] == '' ||
        _userData['Phone number'] == '' ||
        _userData['gender'] == '' ||
        _userData['age'] == '' ||
        _userData['Location'] == '') {
      Toast.show(
          translator.currentLanguage == "en"
              ? "Please complete patient info"
              : 'من فضلك ادخل معلومات المريض',
          context,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM);
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        String isSccuess = '';
//        await Provider.of<Auth>(context, listen: false)
//            .registerUserData(listOfData: _accountData);
        print('isScuessisScuess$isSccuess');
        if (isSccuess == 'success') {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              title: Text("Profile Created"),
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Welcome ${_userData['First name']}",
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                ),
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => complete = true);
                  },
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show("Please try again", context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        Toast.show("Please try again", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    }
  }

  _incrementStep() {
    currentStep + 1 == steps.length
        ? setState(() => complete = true)
        : goTo(currentStep + 1);
  }

  nextStep() async {
    print(steps.length);
    print(currentStep);

    if (currentStep == 0) {
      print(_userData);
      if (_userData['Patient name'] == '' ||
          _userData['Phone number'] == '' ||
          _userData['Location'] == '') {
        Toast.show(
            translator.currentLanguage == "en"
                ? "Please add patient location"
                : 'من فضلك ادخل موقع المريض',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      }
      if (_newAccountKey.currentState.validate()) {
        _newAccountKey.currentState.save();
        _phoneNumberNode.unfocus();
        _incrementStep();
      }
      return;
    }
    if (currentStep == 1) {
      if (_userData['age'] == '' ||
          _userData['month'] == '' ||
          _userData['year'] == '' ||
          _userData['gender'] == '' ||
          _userData['materialStatus'] == '') {
        Toast.show(
            translator.currentLanguage == "en"
                ? "Please Complete data"
                : 'من فضلك اكمل البيانات',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      } else {
        verifyUserData();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
//    SystemChannels.textInput.invokeMethod('TextInput.hide');
    steps = [
      Step(
        title: Text(translator.currentLanguage == "en"
            ? 'Information'
            : 'معلوماتك'),
        isActive: true,
        state: StepState.indexed,
        content: Form(
          key: _newAccountKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _createTextForm(
                  labelText: 'name',
                  nextFocusNode: _phoneNumberNode,
                  // ignore: missing_return
                  validator: (String val) {
                    if (val.trim().isEmpty || val.trim().length < 2) {
                      return translator.currentLanguage == "en"
                          ? 'Please enter your name'
                          : 'من فضلك ادخل اسمك';
                    }
                    if (val.trim().length < 2) {
                      return translator.currentLanguage == "en"
                          ? 'Invalid Name'
                          : 'الاسم خطاء';
                    }
                  }),
              Container(
                padding: EdgeInsets.symmetric(vertical: 7.0),
                height: 80,
                child: TextFormField(
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: translator.currentLanguage == "en"
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
                      return translator.currentLanguage == "en"
                          ? "Please enter National Id!"
                          : 'من فضلك ادخل رقم الهاتف';
                    }
                    if (value.trim().length != 10) {
                      return translator.currentLanguage == "en"
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
//                    _phoneNumberNode.unfocus();
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0),
                height: 80,
                child: TextFormField(
                  autofocus: false,
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
                    labelText: translator.currentLanguage == "en"
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
                ),
              ),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber= number.phoneNumber;
                },
                focusNode: focusNode,
                ignoreBlank: false,
                autoValidate: false,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: controller,
                inputBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                ),
                hintText: translator.currentLanguage == "en" ?'phone number':'رقم الهاتف',
              ),
              SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        translator.currentLanguage == "en" ? 'Birth Date:  ' : 'تاريخ الميلاد:  ',
                        style: TextStyle(fontSize: 18),
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
                            minTime: DateTime.now(),
                            maxTime: DateTime(2080, 6, 7),
                            onChanged: (_) {}, onConfirm: (date) {
                              print('confirm $date');
                              setState(() {
                                _userData['Birth Date'] =
                                '${date.day}-${date.month}-${date.year}';
                              });
                            },
                            currentTime: DateTime.now(),
                            locale: translator.currentLanguage == "en"
                                ? LocaleType.en
                                : LocaleType.ar);
                      },
                      color: Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        translator.currentLanguage == "en"
                            ? '${_userData['Birth Date']}'
                            : '${_userData['Birth Date']}',
                        style:
                        TextStyle(color: Colors.white, fontSize: 18),
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
                        translator.currentLanguage == "en"
                            ? 'Gender:'
                            : 'النوع:',
                        style: TextStyle(fontSize: 18),
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
                                      ? translator.currentLanguage == "en"
                                      ? 'gender'
                                      : 'النوع'
                                      : _userData['gender'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              height: 40,
                              width: 35,
                              child: PopupMenuButton(
                                initialValue: translator.currentLanguage == "en"
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
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          translator.currentLanguage == "en"
                              ? 'Add picture:'
                              : 'اضافه صوره:',
                          style: TextStyle(fontSize: 18),
                          maxLines: 2,
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
                              _openImagePicker();
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                  color: Colors.indigo,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  translator.currentLanguage == "en"
                                      ? " Select Image "
                                      : ' اختر صوره ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(
                                      color: Colors.white,
                                      fontSize: 17),
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
                  ? Container(
                width: double.infinity,
                height: 200,
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      //backgroundColor: Colors.white,
                      //backgroundImage:
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _imageFile,
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
                                _userData['UrlImg'] = '';
                                _imageFile = null;
                                enablePicture = false;
                              });
                            }))
                  ],
                ),
              )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    ];
    return InfoWidget(
      builder: (context, infoWidget) => Directionality(
        textDirection: translator.currentLanguage == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          key: _key,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              translator.currentLanguage == "en"
                  ? 'Add Your information'
                  : 'أدخل معلوماتك',
              style: infoWidget.titleButton,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.indigo,
                    ),
                  )
                      : Stepper(
                    steps: steps,
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
