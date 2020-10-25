import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/shared_widget/show_user_location.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:helpme/screens/user_profile/widgets/personal_info_card.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  static const routeName = 'UserProfile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Auth _auth;

  final GlobalKey<ScaffoldState> _userProfileState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);
    if(_auth.getUserType == 'nurse'){
      getNurseRating();
    }
  }
  getNurseRating(){
    _auth.getNurseRating();
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _userProfileState,
        body: InfoWidget(
          builder: (context, infoWidget) {
            return ListView(
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
                      child: InkWell(
                        onTap: (){
                          if(_auth.userData.imgUrl !='') {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) =>
                                    ShowImage(
                                      title: translator.currentLanguage ==
                                          "en" ? 'personal picture'
                                          : 'الصوره الشخصيه',
                                      imgUrl: _auth.userData.imgUrl,
                                      isImgUrlAsset: false,
                                    )));
                          }
                        },
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
                                    image: _auth.userData.imgUrl)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: infoWidget.screenHeight * 0.02,
                ),
                _auth.userData.name == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'Name'
                            : 'الاسم',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.name
                            : _auth.userData.name,
                        iconData: Icons.person,
                        infoWidget: infoWidget),
                _auth.userData.address == ''
                    ? SizedBox()
                    : InkWell(
                        onTap: () {
                          if (_auth.userData.lat != '') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ShowSpecificUserLocation(
                                      userData: _auth.userData,
                                    )));
                          }
                        },
                        child: personalInfo(
                            title: translator.currentLanguage == "en"
                                ? 'Address'
                                : 'العنوان',
                            subtitle: translator.currentLanguage == "en"
                                ? _auth.userData.address
                                : _auth.userData.address,
                            iconData: Icons.my_location,
                            infoWidget: infoWidget)),
                _auth.userData.specialization== ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'Specialization'
                        : 'التخصص',
                    subtitle:  _auth.userData.specialization,
                    iconData: Icons.school,
                    infoWidget: infoWidget),
                _auth.userData.specializationBranch== ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'Specialization type'
                        : 'نوع التخصص',
                    subtitle:  _auth.userData.specializationBranch,
                    iconData: Icons.info,
                    infoWidget: infoWidget),
                _auth.userData.phoneNumber == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'Phone Number'
                            : 'رقم الهاتف',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.phoneNumber
                            : _auth.userData.phoneNumber,
                        iconData: Icons.phone,
                        infoWidget: infoWidget),
                _auth.userData.email == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'E-mail'
                            : 'البريد الالكترونى',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.email
                            : _auth.userData.email,
                        iconData: Icons.email,
                        infoWidget: infoWidget),
                _auth.getUserType=='nurse'?ListTile(
                  title: Text(
                    translator.currentLanguage == "en" ? 'Rating' : 'التقيم',
                    style:
                        infoWidget.titleButton.copyWith(color: Colors.indigo),
                  ),
                  leading: Icon(
                    Icons.stars,
                    color: Colors.indigo,
                  ),
                  subtitle: Consumer<Auth>(
                    builder: (context,data,_)=>
                    RatingBar(
                      onRatingUpdate: (_){},
                      ignoreGestures: true,
                      initialRating: data.totalRatingForNurse,
                      minRating: 1,
                      itemSize: infoWidget.screenWidth*0.067,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.stars,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ):SizedBox(),
                _auth.userData.nationalId == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'National Id'
                            : 'الرقم القومى',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.nationalId
                            : _auth.userData.nationalId,
                        iconData: Icons.fingerprint,
                        infoWidget: infoWidget),
                _auth.userData.birthDate == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'Birth Date'
                            : 'تاريخ الميلاد',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.birthDate
                            : _auth.userData.birthDate,
                        iconData: Icons.date_range,
                        infoWidget: infoWidget),
                _auth.userData.gender == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'Gender'
                            : 'النوع',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.gender
                            : _auth.userData.gender,
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
                _auth.userData.points == ''
                    ? SizedBox()
                    : personalInfo(
                        title: translator.currentLanguage == "en"
                            ? 'Points'
                            : 'النقاط',
                        subtitle: translator.currentLanguage == "en"
                            ? _auth.userData.points
                            : _auth.userData.points,
                        iconData: Icons.trip_origin,
                        infoWidget: infoWidget),
              ],
            );
          },
        ));
  }
}
