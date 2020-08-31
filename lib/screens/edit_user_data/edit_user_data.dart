import 'dart:io';
import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/edit_user_data/widgets/editImage.dart';
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
  TextEditingController _bioTextEditingController =
      TextEditingController();
  TextEditingController _phoneTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
      if(_auth.userData.phone !=null){
        phone = _auth.userData.phone.substring(1,10);
        _phoneTextEditingController.text = _auth.userData.phone.substring(1,11);
      }
      address = _auth.userData.address;
      addList = translator.currentLanguage == "en" ?['Add Image', 'Add Phone']:['اضافه صوره','اضافه هاتف'];
  }

  getImageFile(File file) {
    _imageFile = file;
  }

  getAddress(String add) {
    address = add;
  }

  getSocialStatus(String social) {
    socialStatus = social;
  }

  editProfile(String type, BuildContext context) {
    if (type == 'image') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
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
                        bool x =await  _auth.editProfile(type: 'image',image: _imageFile);
                        if(x){
                          Toast.show("Scuessfully Editing", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                          Navigator.of(ctx).pop();
                        }else{
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
              ));
    }
    if (type == 'phone') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                contentPadding: EdgeInsets.only(top: 10.0),
                content: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7.0),
                      height: 80,
                      child: TextFormField(
                        controller: _phoneTextEditingController,
                        autofocus: false,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefix: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              "+20",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          labelText: "Phone number",
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
                        onChanged: (value) {
                          phone = value.trim();
                        },
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      if (phone != null && phone.length == 10) {
                        print(phone);
                        bool x =await  _auth.editProfile(type: 'phone',phone: phone,);
                        if(x){
                          Toast.show("Scuessfully Editing", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                          Navigator.of(ctx).pop();
                        }else{
                          Toast.show("Please try again later", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      } else if (phone.length != 10) {
                        Toast.show("Invalid Phone", context,
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.BOTTOM);
                      } else {
                        Toast.show("Please enter your Phone", context,
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
              ));
    }
    if (type == 'address') {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
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
                        bool x =await  _auth.editProfile(type: 'address',address: address,);
                        if(x){
                          Toast.show("Scuessfully Editing", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                          Navigator.of(ctx).pop();
                        }else{
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
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
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
                    //TODO: make pop
                  }),
              actions: <Widget>[
                PopupMenuButton(
                  initialValue: '',
                  tooltip: translator.currentLanguage == "en" ?'Select':'اختار',
                  itemBuilder: (ctx) => addList
                      .map((String val) => PopupMenuItem<String>(
                            value: val,
                            child: Center(child: Text(val.toString())),
                          ))
                      .toList(),
                  onSelected: (val) {
                    if (val == 'Add Image') {
                      editProfile('image', context);
                    }
                    if (val == 'Add Phone') {
                      editProfile('phone', context);
                    }
                  },
                  icon: Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
          ),
          body: Consumer<Auth>(builder: (context,data,_)=>ListView(
            children: <Widget>[
              Padding(
                padding:
                const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
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
                              border: Border.all(color: Colors.indigo),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              //backgroundColor: Colors.white,
                              //backgroundImage:
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
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
                                      bottomRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15)),
                                ),
                                height: 35,
                                child: Row(
                                  textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(translator.currentLanguage == "en" ?'Edit':'تعديل',
                                        style: infoWidget.subTitle
                                            .copyWith(color: Colors.indigo)),
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
              Padding(
                padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                child: Material(
                  shadowColor: Colors.indigoAccent,
                  elevation: 1.0,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  type: MaterialType.card,
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 0.0, left: 10.0, right: 10.0, bottom: 0.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                           '${_auth.userData.name}',
                            style: infoWidget.titleButton.copyWith(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: infoWidget.screenHeight * 0.02,
              ),
              EditPersonalInfoCard(
                title: infoWidget.title,
                orientation: infoWidget.orientation,
                subTitle: infoWidget.titleButton,
                width: infoWidget.screenWidth,
                address: data.userData.address,
                email: data.userData.email,
                gender: data.userData.gender,
                governorate: data.userData.government,
                phoneNumber: data.userData.phone,
                editProfile: editProfile,
              ),
            ],
          ))),
    );
  }
}
