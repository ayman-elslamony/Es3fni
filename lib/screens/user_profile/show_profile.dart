import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/providers/home.dart';
import 'package:helpme/screens/user_profile/widgets/personal_info_card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowUserProfile extends StatefulWidget {
  final String userId;
  final String type;

  ShowUserProfile({this.userId, this.type});

  @override
  _ShowUserProfileState createState() => _ShowUserProfileState();
}

class _ShowUserProfileState extends State<ShowUserProfile> {
  Home _home;
  bool isLoading = true;
  UserData _userData;

Widget  personalInfo(
      {String title,
      String subtitle,
      DeviceInfo infoWidget,
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
      subtitle: Text(
        subtitle,
        style: infoWidget.subTitle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  getUserData() async {
    _userData =
        await _home.getUserData(type: widget.type, userId: widget.userId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.currentLanguage =='en'?TextDirection.ltr:TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                '${widget.type}',
                style: infoWidget.titleButton,
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            Icons.notifications,
                            size: infoWidget.orientation == Orientation.portrait
                                ? infoWidget.screenHeight * 0.04
                                : infoWidget.screenHeight * 0.07,
                          ),
                          Positioned(
                              right: 2.9,
                              top: 2.8,
                              child: Container(
                                width:
                                    infoWidget.orientation == Orientation.portrait
                                        ? infoWidget.screenWidth * 0.023
                                        : infoWidget.screenWidth * 0.014,
                                height:
                                    infoWidget.orientation == Orientation.portrait
                                        ? infoWidget.screenWidth * 0.023
                                        : infoWidget.screenWidth * 0.014,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5)),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size:
                        MediaQuery.of(context).orientation == Orientation.portrait
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.035,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.indigo,
                    ),
                  )
                : ListView(
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
                            child: SizedBox(
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
                                        image: _userData.imgUrl)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: infoWidget.screenHeight * 0.02,
                      ),
                      _userData.name==''?SizedBox():personalInfo(
                          title: translator.currentLanguage == "en"
                              ? 'Name'
                              : 'الاسم',
                          subtitle:
                              translator.currentLanguage == "en" ? _userData.name : _userData.name,
                          iconData: Icons.person,
                          infoWidget: infoWidget),
                      _userData.address==''?SizedBox():personalInfo(
                          title: translator.currentLanguage == "en"
                              ? 'Address'
                              : 'العنوان',
                          subtitle: translator.currentLanguage == "en"
                              ? _userData.address
                              : _userData.address,
                          iconData: Icons.my_location,
                          infoWidget: infoWidget),
                      _userData.phoneNumber==''?SizedBox():
                          InkWell(
                            onTap: (){
                              launch("tel://${_userData.phoneNumber}");
                            },
                              child: personalInfo(
                                  title: translator.currentLanguage == "en"
                                      ? 'Phone Number'
                                      : 'رقم الهاتف',
                                  subtitle: translator.currentLanguage == "en"
                                      ? _userData.phoneNumber
                                      : _userData.phoneNumber,
                                  iconData: Icons.phone,
                                  infoWidget: infoWidget),
                          ),
            _userData.birthDate==''?SizedBox():personalInfo(
                title: translator.currentLanguage == "en"
                    ? 'Birth Date'
                    : 'تاريخ الميلاد',
                subtitle: translator.currentLanguage == "en"
                    ? _userData.birthDate
                    : _userData.birthDate,
                iconData: Icons.date_range,
                infoWidget: infoWidget),
                      _userData.gender==''?SizedBox(): personalInfo(
                          title: translator.currentLanguage == "en"
                              ? 'Gender'
                              : 'النوع',
                          subtitle:
                              translator.currentLanguage == "en" ? _userData.gender : _userData.gender,
                          iconData: Icons.view_agenda,
                          infoWidget: infoWidget),
                      _userData.points==''?SizedBox():personalInfo(
                          title: translator.currentLanguage == "en"
                              ? 'Points'
                              : 'النقاط',
                          subtitle:
                              translator.currentLanguage == "en" ? _userData.points : _userData.points,
                          iconData: Icons.trip_origin,
                          infoWidget: infoWidget),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
