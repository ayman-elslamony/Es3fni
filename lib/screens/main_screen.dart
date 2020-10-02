import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/screens/requests/add_request.dart';
import 'package:helpme/screens/requests/acepted_requests.dart';
import 'package:helpme/screens/requests/all_patient_requests.dart';
import 'package:helpme/screens/requests/all_requests.dart';
import 'package:helpme/screens/requests/archived_requests.dart';
import 'package:helpme/screens/supplies/nurse_supplies.dart';
import 'package:helpme/screens/user_profile/user_profile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'completed_requests/completed_requests.dart';
import 'edit_user_data/edit_user_data.dart';
import 'sign_in_and_up/sign_in/sign_in.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final GlobalKey<ScaffoldState> mainKey = GlobalKey<ScaffoldState>();
  List<String> type = ['Current requests', 'Profile'];
  PageController _pageController;
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _auth = Provider.of<Auth>(context, listen: false);
    if (_auth.getUserType == 'patient') {
      type = translator.currentLanguage == "en"
          ? ['Current requests', 'Profile']
          : ['الطلبات الحاليه', 'الملف الشخصي'];
    } else {
      type = translator.currentLanguage == "en"
          ? ['Accepted requests', 'All Request', 'Profile']
          : ['الطلبات المقبوله', 'كل الطلبات', 'الملف الشخصي'];
    }
    if(_auth.getUserType== 'nurse') {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    if(_auth.getUserType== 'nurse') {
      WidgetsBinding.instance.removeObserver(this);
    }
    _pageController.dispose();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(_auth.getUserType == 'nurse'){
    if (state == AppLifecycleState.resumed)
      _auth.setIsActive();
    else
      _auth.setUnActive();
    }
  }
  Widget _iconNavBar({IconData iconPath, String title, DeviceInfo infoWidget}) {
    return title == null
        ? Icon(
            iconPath,
            color: Colors.white,
          )
        : Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: <Widget>[
                Icon(
                  iconPath,
                  color: Colors.white,
                ),
                title == null
                    ? SizedBox()
                    : Text(
                        title,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
              ],
            ),
          );
  }

  Widget _drawerListTile(
      {String name,
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

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        print(infoWidget.screenWidth);
        print(infoWidget.screenHeight);
        return Directionality(
          textDirection: translator.currentLanguage == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            key: mainKey,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                type[_page],
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
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            drawer: Container(
              width: infoWidget.orientation == Orientation.portrait
                  ? infoWidget.screenWidth * 0.61
                  : infoWidget.screenWidth * 0.50,
              height: infoWidget.screenHeight,
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                Consumer<Auth>(
                builder: (context,data,_)=>UserAccountsDrawerHeader(
                      onDetailsPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          if (_auth.getUserType == 'nurse') {
                            _page = 2;
                          } else {
                            _page = 1;
                          }
                        });
                        _pageController.jumpToPage(_page);
                      },
                      accountName: Text("${data.userData.name.toUpperCase()}"),
                      accountEmail: Text(translator.currentLanguage == "en"
                          ? 'Points: ${data.userData.points}'
                          : ' النقاط: ${data.userData.points}'),
                      currentAccountPicture: ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(15)),
                          child: FadeInImage.assetNetwork(
                              fit: BoxFit.fill,
                              placeholder: 'assets/user.png',
                              image: data.userData.imgUrl)),
                    )),
                    _auth.getUserType != 'nurse'
                        ? _drawerListTile(
                            name: translator.currentLanguage == "en"
                                ? "Current requests"
                                : 'الطلبات الحاليه',
                            isIcon: true,
                            icon: Icons.remove_from_queue,
                            infoWidget: infoWidget,
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _page = 0;
                              });
                              _pageController.jumpToPage(_page);
                            })
                        : _drawerListTile(
                            name: translator.currentLanguage == "en"
                                ? "Accepted requests"
                                : 'الطلبات المقبوله',
                            isIcon: true,
                            icon: Icons.remove_from_queue,
                            infoWidget: infoWidget,
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _page = 0;
                              });
                              _pageController.jumpToPage(_page);
                            }),
                    _auth.getUserType == 'nurse'
                        ? _drawerListTile(
                            name: translator.currentLanguage == "en"
                                ? "All requests"
                                : 'كل الطلبات',
                            isIcon: true,
                            icon: Icons.remove_from_queue,
                            infoWidget: infoWidget,
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _page = 1;
                              });
                              _pageController.jumpToPage(_page);
                            })
                        : SizedBox(),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "User Profile"
                            : 'الملف الشخصي',
                        infoWidget: infoWidget,
                        isIcon: true,
                        icon: Icons.person,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditProfile()));
                        }),
                    _auth.getUserType == 'nurse'
                        ? _drawerListTile(
                            name: translator.currentLanguage == "en"
                                ? "Completed requests"
                                : 'الطلبات المنتهيه',
                            isIcon: true,
                            icon: Icons.archive,
                            infoWidget: infoWidget,
                            onTap: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CompletedRequests()));
                            })
                        : _drawerListTile(
                            name: translator.currentLanguage == "en"
                                ? "Archived requests"
                                : 'الطلبات المؤرشفه',
                            isIcon: true,
                            icon: Icons.archive,
                            infoWidget: infoWidget,
                            onTap: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ArchivedRequests()));
                            }),
                    _auth.getUserType=='patient'?SizedBox():_drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Supplies"
                            : 'التوريدات',
                        isIcon: true,
                        icon: Icons.panorama_fish_eye,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NurseSupplies()));
                        }),

                    _drawerListTile(
                        name: translator.currentLanguage == "ar"
                            ? "English"
                            : "العربية",
                        isIcon: true,
                        icon: Icons.language,
                        infoWidget: infoWidget,
                        onTap: () {
                          translator.currentLanguage == "en"
                              ? translator.setNewLanguage(
                                  context,
                                  newLanguage: 'ar',
                                  remember: true,
                                  restart: true,
                                )
                              : translator.setNewLanguage(
                                  context,
                                  newLanguage: 'en',
                                  remember: true,
                                  restart: true,
                                );
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Log Out"
                            : 'تسجيل الخروج',
                        isIcon: true,
                        icon: Icons.exit_to_app,
                        infoWidget: infoWidget,
                        onTap: () async {
                          await Provider.of<Auth>(context, listen: false)
                              .logout();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignIn()));
                        }),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CurvedNavigationBar(
              height: infoWidget.screenHeight >= 960 ? 70 : 55,
              key: _bottomNavigationKey,
              backgroundColor: Colors.white,
              color: Colors.indigo,
              items: _auth.getUserType == 'nurse'
                  ? <Widget>[
                      _page != 0
                          ? _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.remove_from_queue,
                              title: translator.currentLanguage == "en"
                                  ? "Accepted requests"
                                  : 'الطلبات المقبوله')
                          : _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.remove_from_queue),
                      _page != 1
                          ? _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.redeem,
                              title: translator.currentLanguage == "en"
                                  ? "All requests"
                                  : 'كل الطلبات')
                          : _iconNavBar(
                              infoWidget: infoWidget, iconPath: Icons.redeem),
                      _page != 2
                          ? _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.person,
                              title: translator.currentLanguage == "en"
                                  ? 'Profile'
                                  : 'الملف الشخصى')
                          : _iconNavBar(
                              infoWidget: infoWidget, iconPath: Icons.person),
                    ]
                  : <Widget>[
                      _page != 0
                          ? _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.remove_from_queue,
                              title: translator.currentLanguage == "en"
                                  ? "Current requests"
                                  : 'الطلبات الحاليه')
                          : _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.remove_from_queue),
                      _page != 1
                          ? _iconNavBar(
                              infoWidget: infoWidget,
                              iconPath: Icons.person,
                              title: translator.currentLanguage == "en"
                                  ? 'Profile'
                                  : 'الملف الشخصى')
                          : _iconNavBar(
                              infoWidget: infoWidget, iconPath: Icons.person),
                    ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.jumpToPage(_page);
              },
            ),
            body: Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _page = index;
                  });
                  final CurvedNavigationBarState navBarState =
                      _bottomNavigationKey.currentState;
                  navBarState.setPage(_page);
                },
                children: _auth.getUserType == 'nurse'
                    ? <Widget>[AcceptedRequests(), AllRequests(), UserProfile()]
                    : <Widget>[PatientRequests(), UserProfile()],
              ),
            ),
          ),
        );
      },
    );
  }
}
