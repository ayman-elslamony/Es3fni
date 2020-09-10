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
  String socialStatus;
  String phone;
  bool _isEditLocationEnable = false;
  bool _selectUserLocationFromMap = false;
  List<String> addList = [
    'Add Image',
    'Add Phone',
  ];
  final GlobalKey<ScaffoldState> _userProfileState = GlobalKey<ScaffoldState>();
  TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String phoneNumber;
  FocusNode focusNode=FocusNode();
  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
    address = _auth.userData.address;
    addList = translator.currentLanguage == "en"
        ? ['Add Image', 'Add Phone']
        : ['اضافه صوره', 'اضافه هاتف'];
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getImageFile(File file) {
    _imageFile = file;
  }

  getAddress(String add) {
    address = add;
  }

  editProfile(String type, BuildContext context) {
    if (type == 'image' || type == 'صوره') {
      showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
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
                      child: Text('Ok'),
                      onPressed: () async {
                        if (_imageFile != null) {
                          print(_imageFile);
                          bool x = await _auth.editProfile(
                              type: 'image', image: _imageFile);
                          if (x) {
                            Toast.show("Scuessfully Editing", context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(ctx).pop();
                          } else {
                            Toast.show("Please try again later", context,
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
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
          ));
    }
    if (type == 'Phone Number' || type == 'رقم الهاتف') {
      showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
            child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InternationalPhoneNumberInput(
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
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () async {
                        focusNode.unfocus();
                        if(controller.text.trim().length ==12) {
                         //TODO: save phone
                        }else{
                          Toast.show(translator.currentLanguage == "en" ?'invalid phone number':'الرقم غير صحيح', context);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
          ));
    }
    if (type == 'Address' || type == 'العنوان') {
      showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
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
                      child: Text('Ok'),
                      onPressed: () async {
                        if (address != null) {
                          print(address);
                          bool x = await _auth.editProfile(
                            type: 'address',
                            address: address,
                          );
                          if (x) {
                            Toast.show("Scuessfully Editing", context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(ctx).pop();
                          } else {
                            Toast.show("Please try again later", context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else {
                          Toast.show("Please enter your address", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
          ));
    }
    if (type ==  'Name'
         || type == 'الاسم') {
      showDialog(
          context: context,
          builder: (ctx) => Directionality(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child:  Form(
                  key: formKey,
                  child: Container(
                    height: 80,
                    child: TextFormField(

                      autofocus: false,
                      style: TextStyle(fontSize: 15),
                      controller: _nameTextEditingController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: translator.currentLanguage == "en" ?'Name':'الاسم',
                        focusedBorder: OutlineInputBorder(
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
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        errorStyle: TextStyle(color: Colors.indigo)
                      ),
                      keyboardType: TextInputType.text,
// ignore: missing_return
                      validator: (String val) {
                        if (val.trim().isEmpty) {
                          return translator.currentLanguage == "en" ?'Invalid Name':'الاسم غير صحيح';
                        }
                      },
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () async {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();

                      bool x = await _auth.editProfile(
                        type: 'address',
                        address: address,
                      );
                      if (x) {
                        Toast.show("Scuessfully Editing", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                        Navigator.of(ctx).pop();
                      } else {
                        Toast.show("Please try again later", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      }
                    }
//                  else {
//                    Toast.show(translator.currentLanguage == "en" ?"Please enter your name":'من فضلك ادخل ', context,
//                        duration: Toast.LENGTH_SHORT,
//                        gravity: Toast.BOTTOM);
//                  }
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
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
                editProfile(title, context);
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
                      Navigator.of(context).pop();
                      //TODO: make pop
                    }),
                actions: <Widget>[
                  PopupMenuButton(
                    initialValue: '',
                    tooltip:
                        translator.currentLanguage == "en" ? 'Select' : 'اختار',
                    itemBuilder: (ctx) => addList
                        .map((String val) => PopupMenuItem<String>(
                              value: val,
                              child: Center(child: Text(val.toString())),
                            ))
                        .toList(),
                    onSelected: (val) {
                      if (val == 'Add Image' || val == 'اضافه صوره') {
                        editProfile('image', context);
                      }
                      if (val == 'Add Phone' || val == 'اضافه هاتف') {
                        editProfile('Phone Number', context);
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
                                          editProfile('image', context);
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
                        personalInfo(
                          context: context,
                            title: translator.currentLanguage == "en"
                                ? 'Name'
                                : 'الاسم',
                            subtitle: translator.currentLanguage == "en"
                                ? 'Ayman'
                                : 'أيمن',
                            iconData: Icons.person,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            title: translator.currentLanguage == "en"
                                ? 'Address'
                                : 'العنوان',
                            subtitle: translator.currentLanguage == "en"
                                ? 'Mansoura'
                                : 'المنصوره',
                            iconData: Icons.my_location,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            title: translator.currentLanguage == "en"
                                ? 'Phone Number'
                                : 'رقم الهاتف',
                            subtitle: translator.currentLanguage == "en"
                                ? ''
                                : '01145523795',
                            iconData: Icons.phone,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            enableEdit: false,
                            title: translator.currentLanguage == "en"
                                ? 'National Id'
                                : 'الرقم القومى',
                            subtitle: translator.currentLanguage == "en"
                                ? ''
                                : '1145523795456',
                            iconData: Icons.fingerprint,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            enableEdit: false,
                            title: translator.currentLanguage == "en"
                                ? 'Birth Date'
                                : 'تاريخ الميلاد',
                            subtitle: translator.currentLanguage == "en"
                                ? ''
                                : '7-3-1998',
                            iconData: Icons.date_range,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            enableEdit: false,
                            title: translator.currentLanguage == "en"
                                ? 'Gender'
                                : 'النوع',
                            subtitle:
                                translator.currentLanguage == "en" ? '' : 'ذكر',
                            iconData: Icons.view_agenda,
                            infoWidget: infoWidget),
                        personalInfo(
                            context: context,
                            enableEdit: false,
                            title: translator.currentLanguage == "en"
                                ? 'Points'
                                : 'النقاط',
                            subtitle:
                                translator.currentLanguage == "en" ? '' : '50',
                            iconData: Icons.trip_origin,
                            infoWidget: infoWidget),
                      ],
                    ))),
      ),
    );
  }
}
