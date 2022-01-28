import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/supplying.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NurseSupplies extends StatefulWidget {
  @override
  _NurseSuppliesState createState() => _NurseSuppliesState();
}

class _NurseSuppliesState extends State<NurseSupplies> {
  Home _home;
  Auth _auth;
  bool loadingBody = true;
  Widget content({Supplying supplying, DeviceInfo infoWidget}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        color: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Num of points: ${supplying.points}'
                        : 'عدد النقاط: ${supplying.points}',
                    style: infoWidget.title,
                  ),
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Date: ${supplying.date}'
                        : 'تاريخ: ${supplying.date} ',
                    style: infoWidget.subTitle,
                  ),
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Time: ${supplying.time}'
                        : 'الوقت: ${supplying.time} ',
                    style: infoWidget.subTitle,
                  ),
                ],
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  getSpecificNurseSupplies() async {
    if (_home.allNurseSupplies.length == 0) {
      await _home.getNurseSupplies(userId: _auth.userId);
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);
    getSpecificNurseSupplies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.activeLanguageCode == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getNurseSupplies(userId: _auth.userId);
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  translator.activeLanguageCode == "en"
                      ? "Supplies"
                      : 'التوريدات',
                  style: infoWidget.titleButton,
                ),
                leading: IconButton(icon: Icon(
                  Icons.arrow_back_ios,
                  size: infoWidget.orientation == Orientation.portrait
                      ? infoWidget.screenWidth * 0.05
                      : infoWidget.screenWidth * 0.035,
                ),color: Colors.white, onPressed: () {
                  Navigator.of(context).pop();
                },),
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
              ),
              body: loadingBody
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  itemBuilder: (context, _) =>
                      Shimmer.fromColors(
                        baseColor: Colors.black12.withOpacity(0.1),
                        highlightColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue[100],
                            ),
                            height: infoWidget.screenHeight * 0.15,
                          ),
                        ),
                      ),
                  itemCount: 5,
                ),
              )
                  : Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allNurseSupplies.length == 0) {
                    return Center(
                      child: Text(
                        translator.activeLanguageCode == "en"
                            ? 'there is no any supplies'
                            : 'لا يوجد توريدات',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allNurseSupplies.length,
                        itemBuilder: (context, index) =>
                            content(
                                infoWidget: infoWidget,
                                supplying: data.allNurseSupplies[index]));
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
