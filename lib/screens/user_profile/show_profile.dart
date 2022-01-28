import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:helpme/screens/shared_widget/show_user_location.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
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
  Auth _auth;
  double ratingNurse=0.0;
  Widget personalInfo(
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
    _auth = Provider.of<Auth>(context, listen: false);
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.activeLanguageCode == 'en'
              ? TextDirection.ltr
              : TextDirection.rtl,
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
                                width: infoWidget.orientation ==
                                        Orientation.portrait
                                    ? infoWidget.screenWidth * 0.023
                                    : infoWidget.screenWidth * 0.014,
                                height: infoWidget.orientation ==
                                        Orientation.portrait
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
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
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
                : _userData == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: infoWidget.screenWidth,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Center(
                                        child: Text(
                                  translator.activeLanguageCode == 'en'
                                      ? 'Patient Profile Not Avilable'
                                      : 'الملف الشخصي لهذا المريض غير متاح',
                                  style: infoWidget.titleButton
                                      .copyWith(color: Colors.indigo),
                                ))),
                                SizedBox()
                              ],
                            ),
                          ),
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
                                child: InkWell(
                                  onTap: (){
                                    if(_userData.imgUrl !='') {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) =>
                                              ShowImage(
                                                title: translator.activeLanguageCode ==
                                                    "en" ? 'personal picture'
                                                    : 'الصوره الشخصيه',
                                                imgUrl: _userData.imgUrl,
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          child: FadeInImage.assetNetwork(
                                              fit: BoxFit.fill,
                                              placeholder: 'assets/user.png',
                                              image: _userData.imgUrl)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: infoWidget.screenHeight * 0.02,
                          ),
                          _userData.name == ''
                              ? SizedBox()
                              : personalInfo(
                                  title: translator.activeLanguageCode == "en"
                                      ? 'Name'
                                      : 'الاسم',
                                  subtitle: translator.activeLanguageCode == "en"
                                      ? _userData.name
                                      : _userData.name,
                                  iconData: Icons.person,
                                  infoWidget: infoWidget),
                          _userData.specialization== ''
                              ? SizedBox()
                              : personalInfo(
                                  title: translator.activeLanguageCode == "en"
                                      ? 'Specialization'
                                      : 'التخصص',
                                  subtitle:  _userData.specialization,
                                  iconData: Icons.school,
                                  infoWidget: infoWidget),
                          _userData.specializationBranch== ''
                              ? SizedBox()
                              : personalInfo(
                                  title: translator.activeLanguageCode == "en"
                                      ? 'Specialization'
                                      : 'التخصص',
                                  subtitle:  _userData.specializationBranch,
                                  iconData: Icons.info,
                                  infoWidget: infoWidget),

                          _auth.getUserType != 'nurse'
                              ? SizedBox()
                              : _userData.address == ''
                                  ? SizedBox()
                                  : InkWell(
                                      onTap: _userData.lat != ''
                                          ? () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ShowSpecificUserLocation(
                                                            userData: _userData,
                                                          )));
                                            }
                                          : null,
                                      child: personalInfo(
                                          title:
                                              translator.activeLanguageCode == "en"
                                                  ? 'Address'
                                                  : 'العنوان',
                                          subtitle:
                                              translator.activeLanguageCode == "en"
                                                  ? _userData.address
                                                  : _userData.address,
                                          iconData: Icons.my_location,
                                          infoWidget: infoWidget)),
                          _userData.phoneNumber == ''
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    launch("tel://${_userData.phoneNumber}");
                                  },
                                  child: personalInfo(
                                      title: translator.activeLanguageCode == "en"
                                          ? 'Phone Number'
                                          : 'رقم الهاتف',
                                      subtitle:
                                          translator.activeLanguageCode == "en"
                                              ? _userData.phoneNumber
                                              : _userData.phoneNumber,
                                      iconData: Icons.phone,
                                      infoWidget: infoWidget),
                                ),
                          _auth.getUserType != 'nurse'
                              ? SizedBox()
                              : _userData.birthDate == ''
                                  ? SizedBox()
                                  : personalInfo(
                                      title: translator.activeLanguageCode == "en"
                                          ? 'Birth Date'
                                          : 'تاريخ الميلاد',
                                      subtitle:
                                          translator.activeLanguageCode == "en"
                                              ? _userData.birthDate
                                              : _userData.birthDate,
                                      iconData: Icons.date_range,
                                      infoWidget: infoWidget),
                          _userData.gender == ''
                              ? SizedBox()
                              : personalInfo(
                                  title: translator.activeLanguageCode == "en"
                                      ? 'Gender'
                                      : 'النوع',
                                  subtitle: translator.activeLanguageCode == "en"
                                      ? _userData.gender
                                      : _userData.gender,
                                  iconData: Icons.view_agenda,
                                  infoWidget: infoWidget),
                          _auth.getUserType!='nurse'?ListTile(
                            title: Text(
                              translator.activeLanguageCode == "en" ? 'Rating' : 'التقيم',
                              style:
                              infoWidget.titleButton.copyWith(color: Colors.indigo),
                            ),
                            trailing: RaisedButton(
                              onPressed:()async{
                                ratingNurse = await _home.getSpecificRating(nurseId: _userData.docId,patientId: _auth.userId);
                                showModalBottomSheet(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10))),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) => Directionality(
                                          textDirection: translator.activeLanguageCode=='en'?TextDirection.ltr:TextDirection.rtl,
                                          child: Container(
                                            height: MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                                ? MediaQuery.of(context).size.height * 0.22
                                                : MediaQuery.of(context).size.height * 0.28,
                                            padding: EdgeInsets.all(10.0),
                                            child: Column(children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      translator.activeLanguageCode == "en"

                                                          ? 'Rate the nurse'
                                                          : 'تقيم الممرض',
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(context)
                                                              .orientation ==
                                                              Orientation.portrait
                                                              ? MediaQuery.of(context).size.width *
                                                              0.04
                                                              : MediaQuery.of(context).size.width *
                                                              0.03,
                                                          color: Colors.indigo,
                                                          fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              RatingBar(
                                                onRatingUpdate: (val){
                                                  print(val);
                                                  setState(() {
                                                    ratingNurse = val;
                                                  });
                                                },
                                                initialRating: ratingNurse,
                                                minRating: 1,
                                                itemSize: MediaQuery.of(context).size.width*0.07,
                                                direction: Axis.horizontal,
                                                allowHalfRating: false,
                                                itemCount: 5,
                                                unratedColor: Colors.grey,
                                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                ratingWidget: RatingWidget(full: Icon(
                                    Icons.stars,
                                    color: Colors.indigo,
                                  ), half: Icon(
                                    Icons.stars,
                                    color: Colors.indigo,
                                  ), empty: Icon(
                                    Icons.stars,
                                    color: Colors.grey,
                                  )),
                                              ),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Text(
                                                      translator.activeLanguageCode == "en"
                                                          ? 'OK'
                                                          : 'موافق',
                                                      style:TextStyle(
                                                          fontSize:MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width * 0.035:MediaQuery.of(context).size.width * 0.024,
                                                          color: Colors.indigo,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    onPressed: () async{
                                                      if(ratingNurse != 0) {
                                                        await _home.ratingNurse(
                                                            patientId: _auth.userId,
                                                            nurseId: _userData.docId,
                                                            ratingCount: ratingNurse.floor());
                                                        Navigator.of(context).pop();
                                                      }
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text(
                                                      translator.activeLanguageCode == "en"
                                                          ? 'Cancel'
                                                          : 'الغاء',
                                                      style:TextStyle(
                                                          fontSize:MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width * 0.035:MediaQuery.of(context).size.width * 0.024,
                                                          color: Colors.indigo,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              )
                                            ]),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              color: Colors.indigo,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                child: Text(
                                  translator.activeLanguageCode == "en"
                                      ? 'Rate now'
                                      : 'تقيم الان',
                                  style: infoWidget.subTitle
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                 ),
                            ),
                            leading: Icon(
                              Icons.stars,
                              color: Colors.indigo,
                            ),
                            subtitle: Consumer<Home>(
                              builder: (context,data,_)=>
                                  RatingBar(
                                onRatingUpdate: (_){},
                                ignoreGestures: true,
                                initialRating: data.totalRatingForNurse,
                                minRating: 1,
                                    unratedColor: Colors.grey,
                                itemSize: infoWidget.screenWidth*0.067,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                ratingWidget: RatingWidget(full: Icon(
                                    Icons.stars,
                                    color: Colors.indigo,
                                  ), half: Icon(
                                    Icons.stars,
                                    color: Colors.indigo,
                                  ), empty: Icon(
                                    Icons.stars,
                                    color: Colors.grey,
                                  )),
                              ),
                            ),

                          ):SizedBox(),
                          _userData.aboutYou == ''
                              ? SizedBox()
                              : personalInfo(
                                  title: translator.activeLanguageCode == "en"
                                      ? 'Another Info'
                                      : 'معولمات اخرى',
                                  subtitle: translator.activeLanguageCode == "en"
                                      ? _userData.aboutYou
                                      : _userData.aboutYou,
                                  iconData: Icons.view_agenda,
                                  infoWidget: infoWidget),
                          _auth.getUserType != 'nurse'
                              ? SizedBox()
                              : _userData.points == ''
                                  ? SizedBox()
                                  : personalInfo(
                                      title: translator.activeLanguageCode == "en"
                                          ? 'Points'
                                          : 'النقاط',
                                      subtitle:
                                          translator.activeLanguageCode == "en"
                                              ? _userData.points
                                              : _userData.points,
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
