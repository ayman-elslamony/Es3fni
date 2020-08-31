import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/user_profile/user_profile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

import 'edit_user_data/edit_user_data.dart';
import 'sign_in_and_up/sign_in/sign_in.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textEditingController = TextEditingController();
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final GlobalKey<ScaffoldState> mainKey = GlobalKey<ScaffoldState>();
  List<String> type = ['Home', 'Clinic', 'Profile'];
  PageController _pageController;
  List<String> _searchList = [
    'Search in appointement',
    'Search for doctor',
    'search in history'
  ];
  String _searchContent;
  List<String> _suggestionList = List<String>();
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _auth = Provider.of<Auth>(context, listen: false);
    type = translator.currentLanguage == "en" ?['Home', 'Search', 'Profile']:['الرئيسيه','البحث','الملف الشخصي'];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _iconNavBar(String iconPath, DeviceInfo infoWidget) {
    return ImageIcon(AssetImage(iconPath,
      ),
      size: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth*0.099:infoWidget.screenWidth*0.05,
      color: Colors.white,
    );
  }


  Widget _drawerListTile({String name,
    IconData icon = Icons.settings,
    String imgPath = 'assets/icons/home.png',
    bool isIcon = false,
  DeviceInfo infoWidget,
    Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        dense: true,
        title: Text(
          name,
          style: infoWidget.titleButton.copyWith(color: Colors.indigo),
        ),
        leading: isIcon
            ? Icon(
          icon,
          color: Colors.indigo,
        )
            : Image.asset(
          imgPath,
          color: Colors.indigo,
        ),
      ),
    );
  }
Widget set(){
  if(_auth.getUserType == 'doctor'){
    return Column();
  }
}
  @override
  Widget build(BuildContext context) {
    return  InfoWidget(
      builder: (context, infoWidget) {
        print(infoWidget.screenWidth);print(infoWidget.screenHeight);
        return Directionality(
          textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
          child: Scaffold(
            key: mainKey,
            appBar: AppBar(
              centerTitle: true,
              title: Text(type[_page], style: infoWidget.titleButton,),
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
                            size: infoWidget.orientation==Orientation.portrait?infoWidget.screenHeight * 0.04:infoWidget.screenHeight * 0.07,
                          ),
                          Positioned(
                              right: 2.9,
                              top: 2.8,
                              child: Container(
                                width: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.023:infoWidget.screenWidth * 0.014,
                                height: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.023:infoWidget.screenWidth* 0.014,
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
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            drawer: Container(
              width: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.61:infoWidget.screenWidth * 0.50,
              height: infoWidget.screenHeight,
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                    UserAccountsDrawerHeader(
                      onDetailsPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _page = 2;
                        });
                        _pageController.jumpToPage(_page);
                      },
                      accountName: Text(
                          "${_auth.userData.name.toUpperCase()}}"),
                      accountEmail: Text("${_auth.userData.name}"),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor:
                        Theme
                            .of(context)
                            .platform == TargetPlatform.iOS
                            ? Colors.indigo
                            : Colors.white,
                        child: Text(
                          "${_auth.userData.name.substring(0,1).toUpperCase()
                              .toUpperCase()}",
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    ),
                    _drawerListTile(
                        name: translator.currentLanguage == "en" ?"Home":'الرئيسيه',
                        imgPath: 'assets/icons/home.png',
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 0;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _auth.getUserType == 'doctor'?_drawerListTile(
                        name: "Clinic",
                        imgPath: 'assets/icons/clinic.png',
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 1;
                          });
                          _pageController.jumpToPage(_page);
                        }):_drawerListTile(
                        name: translator.currentLanguage == "en" ?"Search":'بحث',
                        imgPath: 'assets/icons/search.png',
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 1;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en" ?"Edit Profile":'تعديل الحساب',
                        imgPath: 'assets/icons/profile.png',
                        infoWidget: infoWidget,
                        onTap: () {
                          print('njb');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  EditProfile()));
                        }),

//                  _auth.getUserType == 'doctor' ? SizedBox() : _drawerListTile(
//                      name: "Drug List",
//                      isIcon: true,
//                      icon: Icons.assignment,
//                      infoWidget: infoWidget,
//                      onTap: () {
//                        Navigator.of(context)
//                            .push(
//                            MaterialPageRoute(builder: (context) => DrugAndRadiologyAndAnalysis(isDrugs: true,)));
//                      }),
//
                    _drawerListTile(
                        name: translator.currentLanguage == "en" ?"Log Out":'تسجيل الخروج',
                        isIcon: true,
                        icon: Icons.exit_to_app,
                        infoWidget: infoWidget,
                        onTap: () async {
                          await Provider.of<Auth>(context, listen: false)
                              .logout();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SignIn()));
                        }),
                  ],
                ),
              ),
            ),

            bottomNavigationBar: CurvedNavigationBar(
              height: infoWidget
                  .screenHeight >=960?70:50,
              key: _bottomNavigationKey,
              backgroundColor: Colors.white,
              color: Colors.indigo,
              items: <Widget>[
                _page == 0
                    ? _iconNavBar('assets/icons/home.png',infoWidget)
                    : _iconNavBar('assets/icons/homename.png',infoWidget),
                _auth.getUserType == 'doctor'?_page == 1
                    ? _iconNavBar('assets/icons/clinic.png',infoWidget)
                    : _iconNavBar('assets/icons/clinicname.png',infoWidget):_page == 1
                    ? _iconNavBar('assets/icons/search.png',infoWidget)
                    : _iconNavBar('assets/icons/nameSearch.png',infoWidget),
                _page == 2
                    ? _iconNavBar('assets/icons/profile.png',infoWidget)
                    : _iconNavBar('assets/icons/profilename.png',infoWidget),
              ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.jumpToPage(_page);
                _textEditingController.clear();
              },
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                  _textEditingController.clear();
                  final CurvedNavigationBarState navBarState =
                      _bottomNavigationKey.currentState;
                  navBarState.setPage(_page);
                },
                children: <Widget>[
                  Column(),
                 SizedBox(),
                  UserProfile()
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
