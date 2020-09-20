import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/supplying.dart';
import 'package:helpme/models/user_data.dart';
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
                    translator.currentLanguage == 'en'
                        ? 'Num of points: ${supplying.points}'
                        : 'عدد النقاط: ${supplying.points}',
                    style: infoWidget.title,
                  ),
                  Text(
                    translator.currentLanguage == 'en'
                        ? 'Date: ${supplying.date}'
                        : 'تاريخ: ${supplying.date} ',
                    style: infoWidget.subTitle,
                  ),
                  Text(
                    translator.currentLanguage == 'en'
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
          textDirection: translator.currentLanguage == "en"
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
                  translator.currentLanguage == "en"
                      ? "Supplies"
                      : 'التوريدات',
                  style: infoWidget.titleButton,
                ),
              ),
              body: loadingBody
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  itemBuilder: (context, _) => Shimmer.fromColors(
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
                        translator.currentLanguage == "en"
                            ? 'there is no any supplies'
                            : 'لا يوجد توريدات',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allNurseSupplies.length,
                        itemBuilder: (context, index) => content(
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
