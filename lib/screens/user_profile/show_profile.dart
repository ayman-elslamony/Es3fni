import 'package:flutter/material.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/screens/user_profile/widgets/personal_info_card.dart';

class ShowUserProfile extends StatefulWidget {
  final UserData userData;
  final String type;

  ShowUserProfile({this.userData, this.type});

  @override
  _ShowUserProfileState createState() => _ShowUserProfileState();
}

class _ShowUserProfileState extends State<ShowUserProfile> {
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
                        Text('${widget.userData.name}',
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
              PersonalInfoCard(
                title: infoWidget.title,
                email: '',
                orientation: infoWidget.orientation,
                subTitle: infoWidget.titleButton,
                width: infoWidget.screenWidth,
                address: widget.userData.address,
                gender: widget.userData.gender,
                governorate: widget.userData.government,
                phoneNumber: widget.userData.phone,
              ),
            ],
          ),
        );
      },
    );
  }
}
