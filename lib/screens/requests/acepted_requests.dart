import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/requests.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:helpme/screens/user_profile/show_profile.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'add_request.dart';

class AcceptedRequests extends StatefulWidget {
  @override
  _AcceptedRequestsState createState() => _AcceptedRequestsState();
}

class _AcceptedRequestsState extends State<AcceptedRequests> {
  Home _home;
  Auth _auth;
  ScanResult codeSanner;
  bool loadingBody = false;
  bool enableWriteQrCode = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController qrCode = TextEditingController();

  Widget content(
      {Requests request, DeviceInfo infoWidget, BuildContext context}) {
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
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: SizedBox(
                    width: infoWidget.screenWidth,
                    height: infoWidget.screenHeight * 0.55,
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
                                  ? 'All Information'
                                  : 'البيانات بالكامل',
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
                        request.patientName != _auth.userData.name
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  request.patientName != ''
                                      ? Expanded(
                                          child: rowWidget(
                                              title:
                                                  translator.currentLanguage ==
                                                          "en"
                                                      ? 'Patient Name: '
                                                      : 'اسم المريض: ',
                                              content: request.patientName,
                                              infoWidget: infoWidget),
                                        )
                                      : SizedBox(),
                                  IconButton(
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () {
                                        if (request.patientId != '') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowUserProfile(
                                                        type: translator
                                                                    .currentLanguage ==
                                                                "en"
                                                            ? 'Patient'
                                                            : 'مريض',
                                                        userId:
                                                            request.patientId,
                                                      )));
                                        }
                                      })
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
                                onTap: () {
                                  launch("tel://${request.patientPhone}");
                                },
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
                        request.distance != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Distance between you: '
                                : 'المسافه بينكم: ',
                            content:  translator.currentLanguage == "en"
                                ? '${request.distance} KM':'${request.distance} كم ',
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
        child:  Container(
          color: Colors.blue[100],
          child: Padding(
            padding:
            const EdgeInsets.only(top: 10, left: 6,right: 6,bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: infoWidget.screenWidth * 0.06,
                    height: infoWidget.screenWidth * 0.06,
                    child: LoadingIndicator(
                      color: Colors.indigo,
                      indicatorType: Indicator.ballScale,
                    ),
                  ),
                ),
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
                      request.specialization != ''
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            translator.currentLanguage == 'en'
                                ? 'Specialization: '
                                : 'التخصص: ',
                            style: infoWidget.titleButton
                                .copyWith(color: Colors.indigo),
                          ),
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? request.specializationBranch != ''
                                  ? '${request.specialization}-${request
                                  .specializationBranch}'
                                  : '${request.specialization}'
                                  : request.specializationBranch != ''
                                  ? '${request.specialization} - ${request
                                  .specializationBranch}'
                                  : '${request.specialization}',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          RaisedButton(
                            onPressed: () async {
                              bool isFinish = await _home.sendRequestToFinish(
                                  requestId: request.docId);
                              if (isFinish) {
                                await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => StatefulBuilder(
                                      builder: (context, setState) =>
                                          Directionality(
                                            textDirection:
                                            translator.currentLanguage == "en"
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                            child: AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(25.0))),
                                              contentPadding:
                                              EdgeInsets.only(top: 10.0),
                                              title: Text(
                                                translator.currentLanguage == "en"
                                                    ? 'Finish Request'
                                                    : 'انهاء الطلب',
                                                textAlign: TextAlign.center,
                                                style: infoWidget.titleButton
                                                    .copyWith(color: Colors.indigo),
                                              ),
                                              content: Container(
                                                  height: enableWriteQrCode
                                                      ? infoWidget.screenHeight * 0.24
                                                      : infoWidget.screenHeight * 0.16,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      FlatButton(
                                                        padding: EdgeInsets.symmetric(
                                                            vertical: 5, horizontal: 8),
                                                        onPressed: () async {
                                                          codeSanner =
                                                          await BarcodeScanner
                                                              .scan();
                                                          print('codeSanner');
                                                          print(codeSanner.type.name);
                                                          print(codeSanner.rawContent);
                                                          print(request.docId);
                                                          if (codeSanner.type ==
                                                              ResultType.Barcode &&
                                                              codeSanner.rawContent ==
                                                                  request.docId) {
                                                            bool x =
                                                            await _home.endRequest(
                                                                userData:
                                                                _auth.userData,
                                                                request: request);
                                                            if (x) {
                                                              Toast.show(
                                                                  translator.currentLanguage ==
                                                                      "en"
                                                                      ? "Successfully completed"
                                                                      : 'تم الانتهاء بنجاح',
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                  Toast.BOTTOM);
                                                              Navigator.of(ctx).pop();
                                                            } else {
                                                              Toast.show(
                                                                  translator.currentLanguage ==
                                                                      "en"
                                                                      ? "Completion failed"
                                                                      : 'فشل الانتهاء',
                                                                  context,
                                                                  duration: Toast
                                                                      .LENGTH_SHORT,
                                                                  gravity:
                                                                  Toast.BOTTOM);
                                                            }
                                                          } else {
                                                            Toast.show(
                                                                translator.currentLanguage ==
                                                                    "en"
                                                                    ? "Invalid QR Code"
                                                                    : 'رمز الاستجابة السريعة غير صحيح',
                                                                context,
                                                                duration:
                                                                Toast.LENGTH_LONG,
                                                                gravity: Toast.BOTTOM);
                                                          }
                                                        },
                                                        child: Text(
                                                          translator.currentLanguage ==
                                                              "en"
                                                              ? 'Scan QR CODE'
                                                              : 'مسح رمز الاستجابة السريعة',
                                                          style: infoWidget.titleButton
                                                              .copyWith(
                                                              color: Colors.indigo,
                                                              fontWeight:
                                                              FontWeight.bold),
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors.indigo,
                                                                width: 2.0),
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                15.0)),
                                                      ),
                                                      SizedBox(
                                                        height: 4.0,
                                                      ),
                                                      enableWriteQrCode
                                                          ? Form(
                                                          key: _formKey,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                vertical: 7.0),
//                                          height: 75,
                                                            width: infoWidget
                                                                .screenWidth *
                                                                0.41,
                                                            child: TextFormField(
                                                              autofocus: false,
                                                              controller: qrCode,
                                                              textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .indigo),
                                                              decoration:
                                                              InputDecoration(
                                                                labelText: translator
                                                                    .currentLanguage ==
                                                                    "en"
                                                                    ? "QR Code"
                                                                    : 'رمز التحقق',
                                                                focusedBorder:
                                                                OutlineInputBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(Radius
                                                                      .circular(
                                                                      10.0)),
                                                                  borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .indigo,
                                                                  ),
                                                                ),
                                                                errorBorder:
                                                                OutlineInputBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(Radius
                                                                      .circular(
                                                                      10.0)),
                                                                  borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .indigo,
                                                                  ),
                                                                ),
                                                                focusedErrorBorder:
                                                                OutlineInputBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(Radius
                                                                      .circular(
                                                                      10.0)),
                                                                  borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .indigo,
                                                                  ),
                                                                ),
                                                                disabledBorder:
                                                                OutlineInputBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(Radius
                                                                      .circular(
                                                                      10.0)),
                                                                  borderSide:
                                                                  BorderSide(
                                                                    color: Colors
                                                                        .indigo,
                                                                  ),
                                                                ),
                                                                enabledBorder:
                                                                OutlineInputBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(Radius
                                                                      .circular(
                                                                      10.0)),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .indigo),
                                                                ),
                                                                errorStyle: TextStyle(
                                                                    color: Colors
                                                                        .indigo),
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .indigo),
                                                              ),
                                                              keyboardType:
                                                              TextInputType
                                                                  .text,
                                                              validator:
                                                                  // ignore: missing_return
                                                                  (String value) {
                                                                if (value
                                                                    .trim()
                                                                    .isEmpty) {
                                                                  return translator
                                                                      .currentLanguage ==
                                                                      "en"
                                                                      ? "Please enter QR Code!"
                                                                      : 'من فضلك ادخل رمز التحقق';
                                                                }
                                                                if (value
                                                                    .trim()
                                                                    .length <
                                                                    6) {
                                                                  return translator
                                                                      .currentLanguage ==
                                                                      "en"
                                                                      ? "Invalid QR Code!"
                                                                      : 'رمز التحقق خطاء';
                                                                }
                                                                if (value
                                                                    .trim()
                                                                    .toLowerCase() !=
                                                                    request.docId
                                                                        .toLowerCase()
                                                                        .substring(
                                                                        0, 6)) {
                                                                  return translator
                                                                      .currentLanguage ==
                                                                      "en"
                                                                      ? "Invalid QR Code!"
                                                                      : 'رمز التحقق غير صحيح';
                                                                }
                                                              },
                                                            ),
                                                          ))
                                                          : FlatButton(
                                                        padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 8),
                                                        onPressed: () async {
                                                          setState(() {
                                                            enableWriteQrCode =
                                                            true;
                                                          });
                                                        },
                                                        child: Text(
                                                          translator.currentLanguage ==
                                                              "en"
                                                              ? 'Write verification code'
                                                              : 'كتابه كود التحقق',
                                                          style: infoWidget
                                                              .titleButton
                                                              .copyWith(
                                                              color: Colors
                                                                  .indigo,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                        shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .indigo,
                                                                width: 2.0),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                15.0)),
                                                      ),
                                                      SizedBox(
                                                        height: 8.0,
                                                      ),
                                                    ],
                                                  )),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text(
                                                    translator.currentLanguage == "en"
                                                        ? 'Cancel'
                                                        : 'الغاء',
                                                    style: infoWidget.subTitle
                                                        .copyWith(color: Colors.indigo),
                                                  ),
                                                  onPressed: () async {
                                                    bool isCancel =
                                                    await _home.sendRequestToCancel(
                                                        requestId: request.docId);
                                                    if (isCancel) {
                                                      enableWriteQrCode = false;
                                                      qrCode.clear();
                                                      Navigator.of(ctx).pop();
                                                    }
                                                  },
                                                ),
                                                enableWriteQrCode
                                                    ? FlatButton(
                                                  child: Text(
                                                    translator.currentLanguage ==
                                                        "en"
                                                        ? 'Ok'
                                                        : 'تحقق',
                                                    style: infoWidget.subTitle
                                                        .copyWith(
                                                        color: Colors.indigo),
                                                  ),
                                                  onPressed: () async {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      print('iam here');
                                                      bool x =
                                                      await _home.endRequest(
                                                          userData:
                                                          _auth.userData,
                                                          request: request);
                                                      if (x) {
                                                        Toast.show(
                                                            translator.currentLanguage ==
                                                                "en"
                                                                ? "Successfully completed"
                                                                : 'تم الانتهاء بنجاح',
                                                            context,
                                                            duration: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            Toast.BOTTOM);
                                                        Navigator.of(context).pop();
                                                      } else {
                                                        Toast.show(
                                                            translator.currentLanguage ==
                                                                "en"
                                                                ? "Completion failed"
                                                                : 'فشل الانتهاء',
                                                            context,
                                                            duration: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            Toast.BOTTOM);
                                                      }
                                                    }
                                                  },
                                                )
                                                    : SizedBox(),
                                              ],
                                            ),
                                          ),
                                    ));
                              }
                            },
                            color: Colors.white,
                            child: Text(
                              translator.currentLanguage == "en" ? 'Finish Request'
                              : 'انهاء الطلب',
                              style:
                              infoWidget.subTitle.copyWith(color: Colors.indigo),
                            ),
                            padding: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.indigoAccent)),
                          ),SizedBox(width: 3,),
                          RaisedButton(
                            onPressed: () async {
                              bool isFinish = await _home.cancelRequest(
                                  requestId: request.docId);
                              if (isFinish) {
                                Toast.show(
                                    translator.currentLanguage ==
                                        "en"
                                        ? "Cancellation succeeded"
                                        : 'نجح الالغاء',
                                    context,
                                    duration: Toast
                                        .LENGTH_SHORT,
                                    gravity:
                                    Toast.BOTTOM);
                              }else{
                                Toast.show(
                                    translator.currentLanguage ==
                                        "en"
                                        ? "please try again later"
                                        : 'لم ينجح الالغاء',
                                    context,
                                    duration: Toast
                                        .LENGTH_SHORT,
                                    gravity:
                                    Toast.BOTTOM);
                              }
                            },
                            color: Colors.white,
                            child: Text(
                              translator.currentLanguage == "en" ? 'Cancel' : 'الغاء',
                              style:
                              infoWidget.subTitle.copyWith(color: Colors.indigo),
                            ),
                            padding: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.indigoAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  getAllAcceptedRequests() async {
    print('dvdxvx');
    if (_home.allAcceptedRequests.length == 0) {
      setState(() {
        loadingBody = true;
      });
      await _home.getAllAcceptedRequests(userId: _auth.userId,userLat: _auth.userData.lat,userLong: _auth.userData.lng);
      setState(() {
        loadingBody = false;
      });
    }

  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);
    getAllAcceptedRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
        builder: (context, infoWidget) => Scaffold(
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
                        _home.getAllAcceptedRequests(userId: _auth.userId,userLat: _auth.userData.lat,userLong: _auth.userData.lng);
                      },
                      child: Consumer<Home>(
                        builder: (context, data, _) {
                          if (data.allAcceptedRequests.length == 0) {
                            return Center(
                              child: Text(
                                translator.currentLanguage == "en"
                                    ? 'There is no any requests'
                                    : 'لا يوجد طلبات',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.indigo),
                              ),
                            );
                          } else {
                            return ListView.builder(
                                itemCount: data.allAcceptedRequests.length,
                                itemBuilder: (context, index) => content(
                                    context: context,
                                    infoWidget: infoWidget,
                                    request: data.allAcceptedRequests[index]));
                          }
                        },
                      ),
                    ),
            ));
  }
}
