import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/core/ui_components/info_widget.dart';
import 'package:helpme/models/requests.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:helpme/screens/edit_user_data/widgets/edit_address.dart';
import 'package:helpme/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:helpme/screens/user_profile/show_profile.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AllRequests extends StatefulWidget {
  @override
  _AllRequestsState createState() => _AllRequestsState();
}

class _AllRequestsState extends State<AllRequests> {

  Home _home;
  Auth _auth;
  bool loadingBody = false;

  bool _isSpecializationSelected = false;
  bool _showFloating = true;
  ScrollController _scrollController;
  List<String> _specialization = [];

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
                  textDirection: translator.activeLanguageCode == "en"
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: Container(
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
                              translator.activeLanguageCode == "en"
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
                            Expanded(
                              child: rowWidget(
                                  title:
                                  translator.activeLanguageCode ==
                                      "en"
                                      ? 'Patient Name: '
                                      : 'اسم المريض: ',
                                  content: request.patientName,
                                  infoWidget: infoWidget),
                            ),


                            IconButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.indigo,
                                ),
                                onPressed: () {
                                  print(request.patientId);
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
                                })

                          ],
                        )
                            : request.patientName != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
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
                              title: translator.activeLanguageCode == "en"
                                  ? 'Patient Phone: '
                                  : 'رقم الهاتف: ',
                              content: request.patientPhone,
                              infoWidget: infoWidget),
                        )
                            : SizedBox(),
                        request.patientLocation != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Location: '
                                : 'موقع المريض: ',
                            content: request.patientLocation,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.distance != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Distance between you: '
                                : 'المسافه بينكم: ',
                            content: translator.activeLanguageCode == "en"
                                ? '${request.distance} KM' : '${request
                                .distance} كم ',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientAge != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Age: '
                                : 'عمر المريض: ',
                            content: request.patientAge,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientGender != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Gender: '
                                : 'نوع المريض: ',
                            content: request.patientGender,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.serviceType != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Service Type: '
                                : 'نوع الخدمه: ',
                            content: request.serviceType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.servicePrice != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Service Price: '
                                : 'سعر الخدمه: ',
                            content: request.servicePrice,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.analysisType != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Analysis Type: '
                                : 'نوع التحليل: ',
                            content: request.analysisType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.suppliesFromPharmacy != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Supplies From Pharmacy: '
                                : 'مستلزمات من الصيدليه: ',
                            content: request.suppliesFromPharmacy,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.picture != '' ?
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  translator.activeLanguageCode == "en"
                                      ? 'Roshita or analysis Picture: '
                                      : 'صوره الروشته او التحليل: ',
                                  style: infoWidget.titleButton.copyWith(
                                      color: Colors.indigo),
                                ),
                                RaisedButton(
                                  padding: EdgeInsets.all(0.0),
                                  onPressed:
                                      () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            ShowImage(
                                              title: translator
                                                  .currentLanguage == "en"
                                                  ? 'Roshita or analysis Picture'
                                                  : 'صوره الروشته او التحليل',
                                              imgUrl: request.picture,
                                              isImgUrlAsset: false,
                                            )));
                                  },
                                  color: Colors.indigo,
                                  child: Text(
                                    translator.activeLanguageCode == "en"
                                        ? 'Show'
                                        : 'اظهار',
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
                        ) : SizedBox(),
                        request.startVisitDate != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Start Visit Date: '
                                : 'بدايه تاريخ الزياره: ',
                            content: request.startVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.endVisitDate != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'End Visit Date: '
                                : 'انتهاء تاريخ الزياره: ',
                            content: request.endVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitDays != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Visit Days: '
                                : 'ايام الزياره: ',
                            content: visitDays,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitTime != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Visit Time: '
                                : 'وقت الزياره: ',
                            content: visitTime,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountCoupon != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Discount Coupon: '
                                : 'كوبون الخصم: ',
                            content: request.discountCoupon,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountPercentage != '0.0'
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Discount Percentage: '
                                : 'نسبه الخصم: ',
                            content: '${request.discountPercentage} %',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.numOfPatients != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Num Of Patients use service: '
                                : 'عدد مستخدمى الخدمه: ',
                            content: request.numOfPatients,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceBeforeDiscount != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'priceBeforeDiscount: '
                                : 'السعر قبل الخصم: ',
                            content: request.priceBeforeDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceAfterDiscount != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Price After Discount: '
                                : 'السعر بعد الخصم: ',
                            content: request.priceAfterDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.notes != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
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
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.blue[100],
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 6, right: 6, bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: infoWidget.screenWidth * 0.06,
                        height: infoWidget.screenWidth * 0.06,
                        child: LoadingIndicator(
                          colors: [request.nurseId==''?Colors.red:Colors.indigo],
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
                            translator.activeLanguageCode == 'en'
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
                                  translator.activeLanguageCode == 'en'
                                      ? 'Patient Location: ${request
                                      .patientLocation}'
                                      : 'موقع المريض: ${request
                                      .patientLocation}',
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
                            translator.activeLanguageCode == 'en'
                                ? 'Service Type: ${request.serviceType}'
                                : 'نوع الخدمه: ${request.serviceType}',
                            style: infoWidget.titleButton
                                .copyWith(color: Colors.indigo),
                          )
                              : SizedBox(),
                          request.analysisType != ''
                              ? Text(
                            translator.activeLanguageCode == 'en'
                                ? 'Analysis Type: ${request
                                .priceBeforeDiscount} EGP'
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
                                translator.activeLanguageCode == 'en'
                                    ? 'Specialization: '
                                    : 'التخصص: ',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.indigo),
                              ),
                              Expanded(
                                child: Text(
                                  translator.activeLanguageCode == 'en'
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
                            translator.activeLanguageCode == 'en'
                                ? 'Dtate: ${request.date}'
                                : 'التاريخ: ${request.date}',
                            style: infoWidget.subTitle,
                          )
                              : SizedBox(),
                          request.time != ''
                              ? Text(
                            translator.activeLanguageCode == 'en'
                                ? 'Time: ${request.time}'
                                : 'الوقت: ${request.time}',
                            style: infoWidget.subTitle,
                          )
                              : SizedBox(),
                          request.priceBeforeDiscount != ''
                              ? Text(
                            translator.activeLanguageCode == 'en'
                                ? 'Price before discount: ${request
                                .priceBeforeDiscount} EGP'
                                : 'السعر قبل الخصم: ${request
                                .priceBeforeDiscount} جنيه ',
                            style: infoWidget.subTitle,
                          )
                              : SizedBox(),
                          request.priceAfterDiscount != ''
                              ? Text(
                            translator.activeLanguageCode == 'en'
                                ? 'Price after discount: ${request
                                .priceAfterDiscount} EGP'
                                : 'السعر بعد الخصم: ${request
                                .priceAfterDiscount} جنيه ',
                            style: infoWidget.subTitle,
                          )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  request.isLoading
                      ? CircularProgressIndicator(
                    backgroundColor: Colors.indigo,
                  )
                      : RaisedButton(
                    onPressed: () async {
                      setState(() {
                        request.isLoading = true;
                      });
                      _home.acceptRequest(
                          request: request, userData: _auth.userData);
                      setState(() {
                        request.isLoading = false;
                      });
                    },
                    color: Colors.white,
                    child: Text(
                      translator.activeLanguageCode == "en"
                          ? 'Accept'
                          : 'قبول',
                      style: infoWidget.subTitle
                          .copyWith(color: Colors.indigo),
                    ),
                    padding: EdgeInsets.all(0.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.indigoAccent)),
                  ),
                ],
              ),
              bottom: 8.0,
              right: 10.0,
              left: 10.0,
            )
          ],
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

  getAllRequests() async {
    print('dvdxvx');
    if (_home.allPatientsRequests.length == 0) {
      setState(() {
        loadingBody = true;
      });
      final prefs = await SharedPreferences.getInstance();
      Map<String, Object> _filter;

      if(_home.radiusForAllRequests==1.0||
          _home.specializationForAllRequests == ''){
        if (prefs.containsKey('filter')) {
          _filter = await json
              .decode(prefs.getString('filter')) as Map<String, Object>;

          print(_filter['filter']);
          _home.radiusForAllRequests =double.parse(_filter['radiusForAllRequests']??'10.0');

          if(_filter['specialization'] !='') {
           print('A');
//            _isSpecializationSelected = true;
            _home.specializationForAllRequests = _filter['specialization'];
           print('AAA');
            print( _filter['specialization']);
            print( _home.specializationForAllRequests);
          }else{
            print('B');
//            _isSpecializationSelected = true;
            _home.specializationForAllRequests =translator.activeLanguageCode=='en'?'All specialization':'كل التخصصات';
          }
          _auth.lat = double.parse(_filter['lat']);
          _auth.lng = double.parse(_filter['lng']);
          _auth.address = _filter['address'];

        }else{

          _home.radiusForAllRequests = 10.0;
          if (_auth.userData.lat != '' && _auth.userData.lng != '' &&_auth.userData.address!='') {
            _auth.lat = double.parse(_auth.userData.lat);
            _auth.lng = double.parse(_auth.userData.lng);
            _auth.address = _auth.userData.address;
          } else {
            _auth.lat = 30.033333;
            _auth.lng = 31.233334;
            _auth.address = translator.activeLanguageCode=='en'?'Cairo':'القاهره';
          }
//          _isSpecializationSelected = true;
          if(_auth.userData.specialization !=''){
            _home.specializationForAllRequests =_auth.userData.specialization;
          }else{
            _home.specializationForAllRequests =translator.activeLanguageCode=='en'?'All specialization':'كل التخصصات';
          }
        }
      }
      print('_home.specializationForAllRequests');
      print(_home.specializationForAllRequests);
      await _home.getAllRequests(long: _auth.lng.toString(),lat: _auth.lat.toString());
      setState(() {
        if(_home.specializationForAllRequests != ''){
          _isSpecializationSelected = true;
        }
        loadingBody = false;
      });
    }
  }


  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset < (MediaQuery.of(context).size.height*0.1 - kToolbarHeight);
  }
  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);

    _specialization = translator.activeLanguageCode == 'en'
        ? [
      'Human medicine',
      'Physiotherapy',
      'All specialization',
    ]
        : ['طب بشرى', 'علاج طبيعى', 'كل التخصصات'];
    _scrollController = ScrollController()
      ..addListener(() {
        _isAppBarExpanded
            ? setState(() {
          _showFloating = true;
        })
            : setState(() {
          _showFloating = false;
        });
      });
    getAllRequests();
    super.initState();
  }

  getAddress(String add,String lat,String lng) {
    _auth.address = add;
    _auth.lat =double.parse(lat);
    _auth.lng =double.parse(lng);
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
                        _home.getAllRequests(long: _auth.userData.lng,lat: _auth.userData.lat);
                      },
                      child: Consumer<Home>(
                        builder: (context, data, _) {
                          if (data.allPatientsRequests.length == 0) {
                            return Center(
                              child: Text(
                                translator.activeLanguageCode == "en"
                                    ? 'There is no any requests'
                                    : 'لا يوجد طلبات',
                                style: infoWidget.titleButton
                                    .copyWith(color: Colors.indigo),
                              ),
                            );
                          } else {
                            return ListView.builder(
                                controller: _scrollController,
                                itemCount: data.allPatientsRequests.length,
                                itemBuilder: (context, index) => content(
                                    infoWidget: infoWidget,
                                    request: data.allPatientsRequests[index]));
                          }
                        },
                      ),
                    ),
              floatingActionButton: _showFloating?FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10))),
                      context: context,
                      builder: (BuildContext context) {
                        return Directionality(
                          textDirection: translator.activeLanguageCode=='en'?TextDirection.ltr:TextDirection.rtl,
                          child: StatefulBuilder(
                            builder: (context, setState) => Container(
                              height: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? MediaQuery.of(context).size.height * 0.4
                                  : MediaQuery.of(context).size.height * 0.28,
                              padding: EdgeInsets.all(10.0),
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(width: 1.0,)
                                    ,
                                    Text(
                                        translator.activeLanguageCode == "en"
                                            ? 'Filter Requests'
                                            : 'فلتره الطلبات',
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: InkWell(onTap: ()async{
                                        Navigator.of(context).pop();
                                        final prefs = await SharedPreferences.getInstance();
                                        final _filter = json.encode({
                                          'lat': _auth.lat.toString(),
                                          'lng': _auth.lng.toString(),
                                          'address':_auth.address,
                                          'radiusForAllRequests': _home.radiusForAllRequests.toString(),
                                          'specialization': _home.specializationForAllRequests
                                        });
                                        prefs.setString('filter', _filter);
                                        getAllRequests();
                                        }, child: Text(translator.activeLanguageCode == "en" ?'Save':'حفظ',style: infoWidget.subTitle.copyWith(color: Colors.indigo),)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Consumer<Home>(
                                  builder: (context,data,_)=>
                                  Slider(
                                    value: data.radiusForAllRequests,
                                    onChanged: _home.changeRadiusForAllRequests,
                                    min: 0.0,
                                    max: 100.0,
                                    divisions: 10,
                                    label: '${data.radiusForAllRequests.floor()} KM',
                                    inactiveColor: Colors.blue[100],
                                    activeColor: Colors.indigo,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: EditAddress(
                                    getAddress: getAddress,
                                    address: _auth.address,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0,right: 8.0,left: 8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                          vertical: 7,
                                        ),
                                        child: Text(
                                          translator.activeLanguageCode ==
                                              "en"
                                              ? 'Specialization:'
                                              : 'التخصص:',
                                          style: infoWidget
                                              .titleButton
                                              .copyWith(
                                              color: Color(
                                                  0xff484848)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 8.0),
                                        child: Material(
                                          shadowColor:
                                          Colors.blueAccent,
                                          elevation: 2.0,
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  10)),
                                          type: MaterialType.card,
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: translator.activeLanguageCode=='en'?infoWidget.screenWidth*0.27:infoWidget.screenWidth*0.33,
                                                  minWidth: infoWidget.screenWidth*0.012,
                                                ),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 8.0,
                                                      right: 8.0),
                                                  child: Text(
                                                      _isSpecializationSelected ==
                                                          false
                                                          ? translator.activeLanguageCode ==
                                                          "en"
                                                          ? 'Specialization'
                                                          : 'التخصص'
                                                          : _home.specializationForAllRequests,
                                                      style: infoWidget
                                                          .titleButton
                                                          .copyWith(
                                                          color: Color(
                                                              0xff484848))),
                                                ),
                                              ),
                                              Container(
                                                  height: 40,
                                                  width: 35,
                                                  child:
                                                  PopupMenuButton(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        side: BorderSide(color: Colors.indigo)
                                                    ),
                                                    initialValue: translator
                                                        .currentLanguage ==
                                                        "en"
                                                        ? 'All specialization'
                                                        : 'كل التخصصات',
                                                    tooltip:
                                                    'Select Specialization',
                                                    itemBuilder: (ctx) =>
                                                        _specialization
                                                            .map((String
                                                        val) =>
                                                            PopupMenuItem<String>(
                                                              value: val,
                                                              child: Text(val.toString()),
                                                            ))
                                                            .toList(),
                                                    onSelected:
                                                        (val) {

                                                        setState(
                                                                () {
                                                                  _home.specializationForAllRequests =
                                                                  val;
                                                              _isSpecializationSelected =
                                                              true;
                                                            });

                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),]),
                            ),
                          ),
                        );
                      });
                },
                tooltip:
                    translator.activeLanguageCode == "en" ? 'Filter' : 'فلتره',
                child: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                backgroundColor: Colors.indigo,
              ):SizedBox(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            ));
  }
}
