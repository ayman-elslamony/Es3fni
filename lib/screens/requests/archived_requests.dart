
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/requests.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:helpme/screens/user_profile/show_profile.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class ArchivedRequests extends StatefulWidget {
  @override
  _ArchivedRequestsState createState() => _ArchivedRequestsState();
}

class _ArchivedRequestsState extends State<ArchivedRequests> {
  Home _home;
  Auth _auth;
  bool loadingBody = true;

  Widget content({Requests request, DeviceInfo infoWidget}) {
    String visitDays = '';
    String visitTime = '';
    if (request.visitDays != '[]') {
      var x = request.visitDays.replaceFirst('[', '');
      visitDays = x.replaceAll(']', '');
    }
    if (request.visitTime != '[]') {
      var x = request.visitTime.replaceFirst('[', '');
      visitTime = x.replaceAll(']', '');
    }

    print(request.patientName);
    print(request.visitDays);
    print(request.visitTime);
    print(request.discountPercentage);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10))),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Directionality(
                  textDirection: translator.currentLanguage == "en"
                      ? TextDirection.ltr:TextDirection.rtl,
                  child: Container(
                    width: infoWidget.screenWidth,
                    height: infoWidget.screenHeight*0.55,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(),
                            Text(
                              translator.currentLanguage == "en"
                                  ? 'All Information':'البيانات بالكامل',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                            ),
//                          IconButton(
//                              icon: Icon(
//                                Icons.edit,
//                                color: Colors.indigo,
//                              ),
//                              onPressed: () {})
                            SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        request.patientId != ''
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                request.patientName != ''
                                    ? Expanded(
                                      child: rowWidget(
                                      title:
                                      translator.currentLanguage == "en"
                                          ? 'Patient Name: '
                                          : 'اسم المريض: ',
                                      content: request.patientName,
                                      infoWidget: infoWidget),
                                    )
                                    : SizedBox(),
                                request.patientId !='' &&request.patientId!=_auth.userId?IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                                    type: translator.currentLanguage == "en"
                                        ?'Patient':'مريض',
                                    userId: request.patientId,
                                  ) ));
                                }):SizedBox()
                              ],
                            )
                            : request.patientName != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Name: '
                                : 'اسم المريض: ',
                            content: request.patientName,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientPhone != ''
                            ? InkWell(
                          onTap: request.patientPhone!=_auth.userData.phoneNumber?(){

                            launch("tel://${request.patientPhone}");
                          }:null,
                              child: rowWidget(
                              title: translator.currentLanguage == "en"
                                  ? 'Patient Phone: '
                                  : 'رقم الهاتف: ',
                              content: request.patientPhone,
                              infoWidget: infoWidget),
                            )
                            : SizedBox(),
                        request.patientLocation != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Location: '
                                : 'موقع المريض: ',
                            content: request.patientLocation,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientAge != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Age: '
                                : 'عمر المريض: ',
                            content: request.patientAge,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientGender != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Gender: '
                                : 'نوع المريض: ',
                            content: request.patientGender,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.serviceType != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Service Type: '
                                : 'نوع الخدمه: ',
                            content: request.serviceType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.servicePrice != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Service Price: '
                                : 'سعر الخدمه: ',
                            content: request.servicePrice,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.analysisType != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Analysis Type: '
                                : 'نوع التحليل: ',
                            content: request.analysisType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.suppliesFromPharmacy != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Supplies From Pharmacy: '
                                : 'مستلزمات من الصيدليه: ',
                            content: request.suppliesFromPharmacy,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.picture!=''?
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  translator.currentLanguage == "en"
                                      ? 'Roshita or analysis Picture: '
                                      : 'صوره الروشته او التحليل: ',
                                  style: infoWidget.titleButton.copyWith(color: Colors.indigo),
                                ),
                                RaisedButton(
                                  padding: EdgeInsets.all(0.0),
                                  onPressed:
                                      (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowImage(
                                      title: translator.currentLanguage == "en" ? 'Roshita or analysis Picture'
                                          : 'صوره الروشته او التحليل',
                                      imgUrl: request.picture,
                                      isImgUrlAsset: false,
                                    )));
                                  },
                                  color: Colors.indigo,
                                  child: Text(
                                    translator.currentLanguage == "en" ?'Show':'اظهار',
                                    style: infoWidget.titleButton
                                        .copyWith(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ):SizedBox(),
                        request.startVisitDate != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Start Visit Date: '
                                : 'بدايه تاريخ الزياره: ',
                            content: request.startVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.endVisitDate != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'End Visit Date: '
                                : 'انتهاء تاريخ الزياره: ',
                            content: request.endVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitDays != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Visit Days: '
                                : 'ايام الزياره: ',
                            content: visitDays,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitTime != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Visit Time: '
                                : 'وقت الزياره: ',
                            content: visitTime,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountCoupon != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Discount Coupon: '
                                : 'كوبون الخصم: ',
                            content: request.discountCoupon,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountPercentage != '0.0'
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Discount Percentage: '
                                : 'نسبه الخصم: ',
                            content: '${request.discountPercentage} %',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.numOfPatients != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Num Of Patients use service: '
                                : 'عدد مستخدمى الخدمه: ',
                            content: request.numOfPatients,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceBeforeDiscount != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'priceBeforeDiscount: '
                                : 'السعر قبل الخصم: ',
                            content: request.priceBeforeDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceAfterDiscount != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Price After Discount: '
                                : 'السعر بعد الخصم: ',
                            content: request.priceAfterDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.notes != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Notes: '
                                : 'ملاحظات: ',
                            content: request.notes,
                            infoWidget: infoWidget)
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          color: Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      request.patientName != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Patient Name: ${request.patientName}'
                            : 'اسم المريض: ${request.patientName}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.patientLocation != ''
                          ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Patient Location: ${request.patientLocation}'
                                  : 'موقع المريض: ${request.patientLocation}',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(
                            width: 0.1,
                          ),
                        ],
                      )
                          : SizedBox(),
                      request.serviceType != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Service Type: ${request.serviceType}'
                            : 'نوع الخدمه: ${request.serviceType}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.analysisType != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Analysis Type: ${request.priceBeforeDiscount} EGP'
                            : 'نوع التحليل: ${request.analysisType}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.specialization != '' && request.specializationBranch !=''
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            translator.currentLanguage == 'en'
                                ? 'Nurse specialization: '
                                : ' تخصص الممرض: ',
                            style: infoWidget.titleButton
                                .copyWith(color: Colors.indigo),
                          ),
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? request.specializationBranch!=''?'${request.specialization}-${request.specializationBranch}':'${request.specialization}'
                                  : request.specializationBranch!=''?'${request.specialization} - ${request.specializationBranch}':'${request.specialization}',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                          : SizedBox(),
                      request.date != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Dtate: ${request.date}'
                            : 'التاريخ: ${request.date}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.time != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Time: ${request.time}'
                            : 'الوقت: ${request.time}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceBeforeDiscount != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Price before discount: ${request.priceBeforeDiscount} EGP'
                            : 'السعر قبل الخصم: ${request.priceBeforeDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceAfterDiscount != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Price after discount: ${request.priceAfterDiscount} EGP'
                            : 'السعر بعد الخصم: ${request.priceAfterDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.nurseId != ''
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Accepted By Nurse'
                                  : 'تم القبول بواسطه ممرض',
                              style: infoWidget.subTitle,
                            ),
                          ),
                          IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                              type: translator.currentLanguage == "en"
                                  ?'Nurse':'ممرض',
                              userId: request.nurseId,
                            ) ));
                          })
                        ],
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
//                  RaisedButton(onPressed: (){},
//                  child: Text(translator.currentLanguage =='en'?'delete':'حذف',
//                    style: infoWidget.titleButton,),color: Colors.indigo,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
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

  getAllArchivedRequests() async {
    print('dvdxvx');
    if (_home.allArchivedRequests.length == 0) {
      await _home.getAllArchivedRequests(userId: _auth.userId);
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);
    getAllArchivedRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
        builder: (context, infoWidget) => Directionality(
          textDirection: translator.currentLanguage == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                translator.currentLanguage == "en"
                    ? "Archived Requests"
                    : 'الطلبات المؤرشفه',
                style: infoWidget.titleButton,
              ),
              leading: IconButton(icon: Icon(
                Icons.arrow_back_ios,
                size: infoWidget.orientation == Orientation.portrait
                    ? infoWidget.screenWidth * 0.05
                    : infoWidget.screenWidth * 0.035,
              ),color: Colors.white, onPressed: () {
                Navigator.of(context).pop();Navigator.of(context).pop();
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
                      height: infoWidget.screenHeight * 0.27,
                    ),
                  ),
                ),
                itemCount: 5,
              ),
            )
                : RefreshIndicator(
              color: Colors.indigo,
              backgroundColor: Colors.white,
              onRefresh: () async {
                _home.getAllArchivedRequests(userId: _auth.userId);
              },
              child: Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allArchivedRequests.length == 0) {
                    return Center(
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'There is no any archived requests'
                            : 'لا يوجد طلبات مؤرشفه',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allArchivedRequests.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                            request: data.allArchivedRequests[index]));
                  }
                },
              ),
            ),
          ),
        ));
  }
}
