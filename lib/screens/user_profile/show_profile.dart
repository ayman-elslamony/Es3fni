import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/screens/user_profile/widgets/personal_info_card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ShowUserProfile extends StatefulWidget {
  final UserData userData;
  final String type;

  ShowUserProfile({this.userData, this.type});

  @override
  _ShowUserProfileState createState() => _ShowUserProfileState();
}

class _ShowUserProfileState extends State<ShowUserProfile> {

  personalInfo(
      {String title,
        String subtitle,
        DeviceInfo infoWidget,
        IconData iconData}) {
    return ListTile(
      title: Text(
        title,
        style: infoWidget.titleButton.copyWith(color: Colors.indigo),
      ),
      leading:Icon(
        iconData,
        color: Colors.indigo,
      ),
      subtitle: Text(
        subtitle,
        style: infoWidget.subTitle.copyWith(color: Colors.grey[600]),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              '${widget.userData.name}',
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
                  //TODO: make pop
                }),
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            child: FadeInImage.assetNetwork(
                                fit: BoxFit.fill,
                                placeholder: 'assets/user.png',
                                image: widget.userData.imgUrl)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: infoWidget.screenHeight * 0.02,
              ),
              personalInfo(
                  title: translator.currentLanguage == "en" ? 'Name' : 'الاسم',
                  subtitle: translator.currentLanguage == "en" ? '' : 'أيمن',
                  iconData: Icons.person,
                  infoWidget: infoWidget),
              personalInfo(
                  title: translator.currentLanguage == "en" ? 'Address' : 'العنوان',
                  subtitle: translator.currentLanguage == "en" ? '' : 'المنصوره',
                  iconData: Icons.my_location,
                  infoWidget: infoWidget),
              personalInfo(
                  title: translator.currentLanguage == "en"
                      ? 'Phone Number'
                      : 'رقم الهاتف',
                  subtitle: translator.currentLanguage == "en" ? '' : '01144523795',
                  iconData: Icons.phone,
                  infoWidget: infoWidget),
              personalInfo(

                  title:
                  translator.currentLanguage == "en" ? 'National Id' : 'الرقم القومى',
                  subtitle: translator.currentLanguage == "en" ? '' : '1145523795126',
                  iconData: Icons.fingerprint,
                  infoWidget: infoWidget),
              personalInfo(

                  title:
                  translator.currentLanguage == "en" ? 'Birth Date' : 'تاريخ الميلاد',
                  subtitle: translator.currentLanguage == "en" ? '' : '7-3-1998',
                  iconData: Icons.date_range,
                  infoWidget: infoWidget),
              personalInfo(

                  title: translator.currentLanguage == "en" ? 'Gender' : 'النوع',
                  subtitle: translator.currentLanguage == "en" ? '' : 'ذكر',
                  iconData:Icons.view_agenda,
                  infoWidget: infoWidget),
              personalInfo(

                  title: translator.currentLanguage == "en" ? 'Points' : 'النقاط',
                  subtitle: translator.currentLanguage == "en" ? '' : '50',
                  iconData: Icons.trip_origin,
                  infoWidget: infoWidget),
            ],
          ),
        );
      },
    );
  }
}
