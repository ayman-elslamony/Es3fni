import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/edit_user_data/widgets/editImage.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'widgets/edit_address.dart';
import 'widgets/edit_personal_info_card.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Auth _auth;
  File _imageFile;
  String address;
  String lat;
  String lng;
  String socialStatus;
  String phone;
  bool _isEditLocationEnable = false;
  bool _selectUserLocationFromMap = false;
  List<String> addList = [];
  final GlobalKey<ScaffoldState> _userProfileState = GlobalKey<ScaffoldState>();
  TextEditingController _anotherInfoTextEditingController =
      TextEditingController();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String phoneNumber;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
    address = _auth.userData.address;
    if (_auth.getUserType == 'nurse') {
      addList = translator.currentLanguage == "en"
          ? ['Add Image', 'Add Phone', 'Add Address', 'Add Another Info']
          : ['اضافه صوره', 'اضافه هاتف', 'اضافه عنوان', 'اضافه معلومات اخرى'];
    } else {
      addList = translator.currentLanguage == "en"
          ? ['Add Image','Add Address']
          : ['اضافه صوره','اضافه عنوان',];
    }
    if(_auth.userData.phoneNumber.contains('+20')){
      String phoneNumber = _auth.userData.phoneNumber.replaceAll('+20', '');
      String dialCode = '+20';
      number = PhoneNumber(isoCode: 'EG',dialCode: dialCode,phoneNumber: phoneNumber);
    }else{
      number = PhoneNumber(phoneNumber:  _auth.userData.phoneNumber);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getImageFile(File file) {
    _imageFile = file;
  }

  getAddress(String add,String lat,String lng) {
    address = add;
    this.lat =lat;
    this.lng =lng;
  }

  editProfile(String type, BuildContext context,DeviceInfo deviceInfo) {
    if (type == 'image' || type == 'صوره') {
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.18,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EditImage(
                          imgUrl: _auth.userData.imgUrl,
                          getImageFile: getImageFile,
                        ),
                      )),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (_imageFile != null) {
                          print(_imageFile);
                          bool x = await _auth.editProfile(
                              type: 'image', picture: _imageFile);
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else {
                          Toast.show("Please enter your Image", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Phone Number' || type == 'رقم الهاتف') {

      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        phoneNumber = number.phoneNumber;
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
                      hintText: translator.currentLanguage == "en"
                          ? 'phone number'
                          : 'رقم الهاتف',
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        focusNode.unfocus();
                        if (controller.text.trim().length == 12 && phoneNumber != _auth.userData.phoneNumber ) {
                          bool x = await _auth.editProfile(
                            type: 'Phone Number',
                            phone: phoneNumber.toString(),
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else if(phoneNumber == _auth.userData.phoneNumber ){
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'Already exists'
                                  : 'الرقم موجود بالفعل',
                              context);
                        }else {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'invalid phone number'
                                  : 'الرقم غير صحيح',
                              context);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Address' || type == 'العنوان') {
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EditAddress(
                        getAddress: getAddress,
                        address: _auth.userData.address,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (address != null&& address != _auth.userData.address) {
                          print(address);
                          bool x = await _auth.editProfile(
                            type: 'Address',
                            lat: lat,
                            lng: lng,
                            address: address,
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        }  else if(address == _auth.userData.address){
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? "Already exists"
                                  : 'العنوان موجود بالفعل',
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }else {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? "Please enter your address"
                                  : 'من فضلك ادخل العنوان',
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Another Info' || type == 'معلومات اخرى') {
      _anotherInfoTextEditingController.text = _auth.userData.aboutYou;
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: StatefulBuilder(
                    builder: (context, setState) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: formKey,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(vertical: 7.0),
                          child: TextFormField(
                            controller: _anotherInfoTextEditingController,
                            autofocus: false,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: translator.currentLanguage == "en"
                                  ? "Another Info"
                                  : 'معلومات اخرى',
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.indigo),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                            minLines: 2,
                            // ignore: missing_return
                            validator: (val) {
                              if (val.trim().length == 0) {
                                return translator.currentLanguage=='en'?'Please write some info':'من فضلك ادخل بعض البيانات';
                              }
                              if (val.trim() == _auth.userData.aboutYou) {
                                return translator.currentLanguage=='en'?'Already exists':'موجود بالفعل';
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();

                          bool x = await _auth.editProfile(
                            type: 'Another Info',
                            aboutYou: _anotherInfoTextEditingController.text,
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
  }

  personalInfo(
      {String title,
      String subtitle,
      DeviceInfo infoWidget,
      bool enableEdit = true,
      BuildContext context,
      IconData iconData}) {
    return ListTile(
      title: Text(
        title,
        style: infoWidget.titleButton.copyWith(color: Colors.indigo),
      ),
      leading: Icon(
        iconData,
        color: Colors.indigo,
      ),
      trailing: enableEdit
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.indigo,
              ),
              onPressed: () {
                editProfile(title, context,infoWidget);
              })
          : null,
      subtitle: Text(
        subtitle,
        style: infoWidget.subTitle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.currentLanguage == "en"
          ? TextDirection.ltr
          : TextDirection.rtl,
      child: InfoWidget(
        builder: (context, infoWidget) => Scaffold(
            key: _userProfileState,
            appBar: PreferredSize(
              preferredSize: Size(
                  infoWidget.screenWidth,
                  infoWidget.orientation == Orientation.portrait
                      ? infoWidget.screenHeight * 0.075
                      : infoWidget.screenHeight * 0.09),
              child: AppBar(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40))),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: infoWidget.orientation == Orientation.portrait
                          ? infoWidget.screenWidth * 0.05
                          : infoWidget.screenWidth * 0.035,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                actions: <Widget>[
                  PopupMenuButton(
                    initialValue: '',
                    tooltip:
                        translator.currentLanguage == "en" ? 'Select' : 'اختار',
                    itemBuilder: (context) => addList
                        .map((String val) => PopupMenuItem<String>(
                              value: val,
                              child: Center(child: Text(val.toString())),
                            ))
                        .toList(),
                    onSelected: (val) {
                      if (val == 'Add Image' || val == 'اضافه صوره') {
                        editProfile('image', context,infoWidget);
                      }
                      if (val == 'Add Phone' || val == 'اضافه هاتف') {
                        editProfile('Phone Number', context,infoWidget);
                      }
                      if (val == 'Add Address' || val == 'اضافه عنوان') {
                        editProfile('Address', context,infoWidget);
                      }
                      if (val == 'Add Another Info' ||
                          val == 'اضافه معلومات اخرى') {
                        editProfile('Another Info', context,infoWidget);
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                    ),
                  ),
                ],
              ),
            ),
            body: Consumer<Auth>(
                builder: (context, data, _) => ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 2.0, right: 2.0),
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                              ),
                              color: Colors.indigo,
                            ),
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  SizedBox(
                                    width: 160,
                                    height: 130,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.indigo),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ClipRRect(
                                          //backgroundColor: Colors.white,
                                          //backgroundImage:
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          child: FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              placeholder: 'assets/user.png',
                                              image: data.userData.imgUrl)),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0.0,
                                      right: 0.0,
                                      left: 0.0,
                                      child: InkWell(
                                        onTap: () {
                                          editProfile('image', context,infoWidget);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(15),
                                                bottomLeft:
                                                    Radius.circular(15)),
                                          ),
                                          height: 35,
                                          child: Row(
                                            textDirection:
                                                translator.currentLanguage ==
                                                        "en"
                                                    ? TextDirection.ltr
                                                    : TextDirection.rtl,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  translator.currentLanguage ==
                                                          "en"
                                                      ? 'Edit'
                                                      : 'تعديل',
                                                  style: infoWidget.subTitle
                                                      .copyWith(
                                                          color:
                                                              Colors.indigo)),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.edit,
                                                color: Colors.indigo,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: infoWidget.screenHeight * 0.02,
                        ),
                        data.userData.name == ''
                            ? SizedBox()
                            : personalInfo(
                                context: context,
                                enableEdit: false,
                                title: translator.currentLanguage == "en"
                                    ? 'Name'
                                    : 'الاسم',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.name
                                    : data.userData.name,
                                iconData: Icons.person,
                                infoWidget: infoWidget),
                        data.userData.address == ''
                            ? SizedBox()
                            : personalInfo(
                                context: context,
                                title: translator.currentLanguage == "en"
                                    ? 'Address'
                                    : 'العنوان',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.address
                                    : data.userData.address,
                                iconData: Icons.my_location,
                                infoWidget: infoWidget),
                         data.userData.phoneNumber == ''
                                ? SizedBox()
                                : personalInfo(
                                    context: context,
                                    enableEdit: _auth.getUserType == 'nurse'
                                        ?true:false,
                                    title: translator.currentLanguage == "en"
                                        ? 'Phone Number'
                                        : 'رقم الهاتف',
                                    subtitle: translator.currentLanguage == "en"
                                        ? data.userData.phoneNumber
                                        : data.userData.phoneNumber,
                                    iconData: Icons.phone,
                                    infoWidget: infoWidget)
                            ,
                        data.userData.email == ''
                            ? SizedBox()
                            : personalInfo(
                                title: translator.currentLanguage == "en"
                                    ? 'E-mail'
                                    : 'البريد الالكترونى',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.email
                                    : data.userData.email,
                                iconData: Icons.email,
                                enableEdit: false,
                                context: context,
                                infoWidget: infoWidget),
                        data.userData.nationalId == ''
                            ? SizedBox()
                            : personalInfo(
                                context: context,
                                enableEdit: false,
                                title: translator.currentLanguage == "en"
                                    ? 'National Id'
                                    : 'الرقم القومى',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.nationalId
                                    : data.userData.nationalId,
                                iconData: Icons.fingerprint,
                                infoWidget: infoWidget),
                        data.userData.birthDate == ''
                            ? SizedBox()
                            : personalInfo(
                                context: context,
                                enableEdit: false,
                                title: translator.currentLanguage == "en"
                                    ? 'Birth Date'
                                    : 'تاريخ الميلاد',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.birthDate
                                    : data.userData.birthDate,
                                iconData: Icons.date_range,
                                infoWidget: infoWidget),
                        data.userData.gender == ''
                            ? SizedBox()
                            : personalInfo(
                                context: context,
                                enableEdit: false,
                                title: translator.currentLanguage == "en"
                                    ? 'Gender'
                                    : 'النوع',
                                subtitle: translator.currentLanguage == "en"
                                    ? data.userData.gender
                                    : data.userData.gender,
                                iconData: Icons.view_agenda,
                                infoWidget: infoWidget),
                        _auth.userData.aboutYou == ''
                            ? SizedBox()
                            : personalInfo(
                                title: translator.currentLanguage == "en"
                                    ? 'Another Info'
                                    : 'معلومات اخرى',
                                subtitle: translator.currentLanguage == "en"
                                    ? _auth.userData.aboutYou
                                    : _auth.userData.aboutYou,
                                iconData: Icons.info,
                                infoWidget: infoWidget),
                      ],
                    ))),
      ),
    );
  }
}
