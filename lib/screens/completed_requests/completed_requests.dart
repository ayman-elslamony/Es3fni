
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/completed_request.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CompletedRequests extends StatefulWidget {
  @override
  _CompletedRequestsState createState() => _CompletedRequestsState();
}

class _CompletedRequestsState extends State<CompletedRequests> {
  Home _home;
  Auth
  _auth;
  bool loadingBody = true;


  Widget rowWidget({String title, String content, DeviceInfo infoWidget}) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              title,
              style: infoWidget.titleButton.copyWith(color: Colors.indigo),
            ),
            Expanded(
              child: Text(
                content,
                style: infoWidget.subTitle,
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }
  Widget content({CompleteRequest completeRequest, DeviceInfo infoWidget}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        color: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            children: <Widget>[
              completeRequest.serviceType != ''
                  ? rowWidget(
                  title: translator.currentLanguage == "en"
                      ? 'Service Type: '
                      : 'نوع الخدمه: ',
                  content: completeRequest.serviceType,
                  infoWidget: infoWidget)
                  : SizedBox(),
              completeRequest.analysisType != ''
                  ? rowWidget(
                  title: translator.currentLanguage == "en"
                      ? 'Analysis Type: '
                      : 'نوع التحليل: ',
                  content: completeRequest.analysisType,
                  infoWidget: infoWidget)
                  : SizedBox(),
              completeRequest.date != ''
                  ? rowWidget(
                  title: translator.currentLanguage == "en"
                      ? 'Date: '
                      : 'التاريخ: ',
                  content: completeRequest.date,
                  infoWidget: infoWidget)
                  : SizedBox(),
              completeRequest.time != ''
                  ? rowWidget(
                  title: translator.currentLanguage == "en"
                      ? 'Time: '
                      : 'الوقت: ',
                  content: completeRequest.time,
                  infoWidget: infoWidget)
                  : SizedBox(),
              completeRequest.points != ''
                  ? rowWidget(
                  title: translator.currentLanguage == "en"
                      ? 'points: '
                      : 'النقاط: ',
                  content: completeRequest.points,
                  infoWidget: infoWidget)
                  : SizedBox(),

            ],
          ),
        ),
      ),
    );
  }
  getAllCompletedRequest() async {
    if (_home.allCompleteRequests.length == 0) {
      await _home.getAllCompletedRequests(userId: _auth.userId);
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _auth = Provider.of<Auth>(context, listen: false);
    _home = Provider.of<Home>(context, listen: false);
    getAllCompletedRequest();
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
              await _home.getAllCompletedRequests(userId: _auth.userId);
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  translator.currentLanguage == "en"
                      ? "Completed Request"
                      : 'الطلبات المنتهيه',
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
                  if (data.allCompleteRequests.length == 0) {
                    return Center(
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'there is no any completed request'
                            : 'لا يوجد طلبات منتهيه',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allCompleteRequests.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                            completeRequest: data.allCompleteRequests[index]));
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
