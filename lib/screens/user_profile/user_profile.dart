import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/user_profile/widgets/personal_info_card.dart';
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
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _userProfileState,
        body: InfoWidget(
          builder: (context,infoWidget){
            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0,left: 2.0,right: 2.0),
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
                          decoration:
                          BoxDecoration(
                            border: Border.all(color: Colors.indigo),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            //backgroundColor: Colors.white,
                            //backgroundImage:
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              child:
                              FadeInImage.assetNetwork(fit: BoxFit.fill,placeholder: 'assets/user.png',image: _auth.userData.imgUrl)
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: infoWidget.screenHeight*0.02,),
                PersonalInfoCard(
                  title: infoWidget.title,
                  orientation: infoWidget.orientation,
                  subTitle: infoWidget.titleButton,
                  width: infoWidget.screenWidth,
                  address: _auth.userData.address,
                  email: _auth.userData.email,
                  gender: _auth.userData.gender,
                  governorate: _auth.userData.government,
                  phoneNumber: _auth.userData.phone,
                ),
              ],
            );
          },
        ));
  }
}
