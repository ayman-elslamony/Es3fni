import 'dart:io';
import 'dart:math';
import 'package:helpme/models/completed_request.dart';
import 'package:helpme/models/supplying.dart';
import 'package:helpme/models/user_data.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:helpme/models/analysis.dart';
import 'package:helpme/models/coupon.dart';
import 'package:helpme/models/price.dart';
import 'package:helpme/models/requests.dart';
import 'package:helpme/models/service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Home with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseFirestore.instance;
//  final String authToken;
//  final String authId;
//
//  Home(
//    this.authToken,
//    this.authId,
//  );
  List<Service> allService = [];
  List<Analysis> allAnalysis = [];
  List<String> allServicesType =
      translator.activeLanguageCode == "en" ? ['Analysis'] : ['تحاليل'];
  List<String> allAnalysisType = [];
  List<Requests> allPatientsRequests = [];
  List<Requests> allAcceptedRequests = [];
  List<Requests> allPatientRequests = [];
  List<Requests> allArchivedRequests = [];
  List<Supplying> allNurseSupplies = [];
  List<CompleteRequest> allCompleteRequests = [];
  double totalRatingForNurse = 0.0;
  double radiusForAllRequests= 1.0;
  String specializationForAllRequests= '';
  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon = Coupon(
      docId: '', couponName: '', discountPercentage: '0.0', numberOfUses: '0');
  double discount = 0.0;
  double priceBeforeDiscount = 0.0;

  Future<void> unVerifyCoupon() async {
    double prices = price.servicePrice;
    List<String> x = price.allServiceType;
    price = Price(
        servicePrice: (prices + discount),
        isAddingDiscount: false,
        allServiceType: x);
    notifyListeners();
  }
  addToPrice({String type, String serviceType}) {
    if (type == 'analysis') {
      if (!price.allServiceType.contains(serviceType)) {
        int index =
            allAnalysis.indexWhere((x) => x.analysisName == serviceType);
        List<String> x = price.allServiceType;
        x.add(serviceType);
//       priceBeforeDiscount =price.servicePrice + double.parse(allAnalysis[index].price);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allAnalysis[index].price),
            allServiceType: x);
      }
    } else {
      if (!price.allServiceType.contains(serviceType)) {
        int index = allService.indexWhere((x) => x.serviceName == serviceType);
        List<String> x = price.allServiceType;
        // priceBeforeDiscount =price.servicePrice + double.parse(allService[index].price);
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allService[index].price),
            allServiceType: x);
      }
    }
    notifyListeners();
  }
  setPriceDuringEditRequest({Requests request}){
    coupon = Coupon(
      docId: '',
      couponName:request.discountCoupon,
      discountPercentage: request.discountPercentage,
    );
    double prices =price.servicePrice;
    priceBeforeDiscount = price.servicePrice;
    discount = prices * (double.parse(coupon.discountPercentage) / 100);
    List<String> x = price.allServiceType;
    price = Price(
        servicePrice: (prices - discount),
        isAddingDiscount: true,
        allServiceType: x);
  }
  resetPrice() {
    price = Price(allServiceType: [], servicePrice: 0.0);
  }
  getData({document,String key,String ifNull=''}){
    return document.toString().contains(key)?document[key]:ifNull;
  }
  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.get();
    allService.clear();
    allServicesType =
        translator.activeLanguageCode == "en" ? ['Analysis'] : ['تحاليل'];
    if (docs.docs.isNotEmpty) {
      for (int i = 0; i < docs.docs.length; i++) {
        allService.add(Service(
          id: docs.docs[i].id,
          price: docs.docs[i]['price'],
          serviceName: docs.docs[i]['serviceName'],
        ));
        allServicesType.add(docs.docs[i]['serviceName']);
      }
    }
    notifyListeners();
  }

  Future getAllAnalysis() async {
    var analysis = databaseReference.collection("analysis");
    var docs = await analysis.get();
    if (docs.docs.length != 0) {
      allAnalysis.clear();
      allAnalysisType.clear();
      for (int i = 0; i < docs.docs.length; i++) {
        allAnalysis.add(Analysis(
          id: docs.docs[i].id,
          price: docs.docs[i]['price'],
          analysisName: docs.docs[i]['analysisName'],
        ));
        allAnalysisType.add(docs.docs[i]['analysisName']);
      }
    }
    notifyListeners();
  }
  changeRadiusForAllRequests(double val){
    radiusForAllRequests = val;
    notifyListeners();
  }
  Future getAllRequests({String lat='0.0',String long='0.0'}) async {
    List<String> specialization=[''];
    if(specializationForAllRequests=='All specialization'||specializationForAllRequests=='كل التخصصات'){
      specialization =  ['','Human medicine',
    'Physiotherapy',
    'طب بشرى', 'علاج طبيعى'];
    }else if(specializationForAllRequests=='Human medicine'||specializationForAllRequests=='طب بشرى'){
      specialization = ['Human medicine','طب بشرى'];
    }else{
    specialization =['Physiotherapy','علاج طبيعى'];
    }
    CollectionReference requests = databaseReference.collection('requests');
    requests.where('nurseId', isEqualTo: '').where('specialization',whereIn: specialization).snapshots().listen((docs) {
      print(docs.docs);
      allPatientsRequests.clear();
      double distance = 0.0;
      print('A');
      if (docs.docs.length != 0) {
        print('B');
        String time = '';
        String acceptTime = '';
        List<String> convertAllVisitsTime = [];
        for (int i = 0; i < docs.docs.length; i++) {
          print('userlat:$lat');
          //print('lat:${docs.docs[i]['lat')}');
          print('userlng:$long');
        //  print('lng:${docs.docs[i]['long')}');
          distance = _calculateDistance(
              lat != '0.0' ? double.parse(lat) : 0.0,
              long != '0.0' ? double.parse(long) : 0.0,
              double.parse(docs.docs[i]['lat']??'0.0'),
              double.parse(docs.docs[i]['long']??'0.0'));
          print('distance::$distance');

          if (distance <= radiusForAllRequests) {
            if (docs.docs[i]['time'] != '') {
              time = convertTimeToAMOrPM(time: docs.docs[i]['time']);
            } else {
              time = '';
            }
            if (docs.docs[i]['acceptTime'] != null&&docs.docs[i]['acceptTime'] != '') {
              acceptTime = convertTimeToAMOrPM(
                  time: docs.docs[i]['acceptTime']);
            } else {
              acceptTime = '';
            }
            if (docs.docs[i]['visitTime'] != '[]') {
              var x = docs.docs[i]['visitTime']
                  .replaceFirst('[', '')
                  .toString();
              String visitTime = x.replaceAll(')', '');
              List<String> times = visitTime.split(',');
              if (times.length != 0) {
                for (int i = 0; i < times.length; i++) {
                  convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
                }
              }
            } else {
              convertAllVisitsTime = [];
            }
            allPatientsRequests.add(
                Requests(
                specialization: docs.docs[i]['specialization'] ?? '',
                specializationBranch: docs.docs[i]['specializationBranch'] ?? '',
                distance:  distance.floor().toString(),
                lat: docs.docs[i]['lat'] ?? '',
                long: docs.docs[i]['long'] ?? '',
                acceptTime: acceptTime,
                nurseId: docs.docs[i]['nurseId'] ?? '',
                patientId: docs.docs[i]['patientId'] ?? '',
                docId: docs.docs[i].id,
                visitTime: convertAllVisitsTime.toString() == '[]'
                    ? ''
                    : convertAllVisitsTime.toString(),
                visitDays: docs.docs[i]['visitDays'] == '[]'
                    ? ''
                    : docs.docs[i]['visitDays'] ?? '',
                suppliesFromPharmacy:
                docs.docs[i]['suppliesFromPharmacy'] ?? '',
                startVisitDate: docs.docs[i]['startVisitDate'] ?? '',
                serviceType: docs.docs[i]['serviceType'] ?? '',
                picture: docs.docs[i]['picture'] ?? '',
                patientPhone: docs.docs[i]['patientPhone'] ?? '',
                patientName: docs.docs[i]['patientName'] ?? '',
                patientLocation: docs.docs[i]['patientLocation'] ??
                    '',
                patientGender: docs.docs[i]['patientGender'] ?? '',
                patientAge: docs.docs[i]['patientAge'] ?? '',
                servicePrice: docs.docs[i]['servicePrice'] ?? '',
                time: time,
                date: docs.docs[i]['date'] ?? '',
                discountPercentage:
                docs.docs[i]['discountPercentage'] ?? '',
                nurseGender: docs.docs[i]['nurseGender'] ?? '',
                numOfPatients: docs.docs[i]['numOfPatients'] ?? '',
                endVisitDate: docs.docs[i]['endVisitDate'] ?? '',
                discountCoupon: docs.docs[i]['discountCoupon'] ?? '',
                priceBeforeDiscount:
                docs.docs[i]['priceBeforeDiscount'] ?? '',
                analysisType: docs.docs[i]['analysisType'] ?? '',
                notes: docs.docs[i]['notes'] ?? '',
                priceAfterDiscount:
                docs.docs[i]['priceAfterDiscount'].toString() ??
                    ''));
          }
          print('dfbfdsndd');
          print(allPatientsRequests.length);
        }
        } else {
        allPatientsRequests.clear();
      }
      notifyListeners();
    });
  }

Future<double> getSpecificRating({String nurseId,String patientId})async{
  CollectionReference patientCollection = databaseReference.collection("users");
  double rating =0.0;
  DocumentSnapshot x = await patientCollection.doc(patientId).collection('rating').doc(nurseId).get();
    if(x.exists){
      rating = double.parse(x['rating']);
    }
   return rating;
}
  Future<void> ratingNurse({int ratingCount,String nurseId,String patientId})async{
    CollectionReference nurses= databaseReference.collection("nurses");
    CollectionReference patientCollection = databaseReference.collection("users");
    DocumentSnapshot x = await patientCollection.doc(patientId).collection('rating').doc(nurseId).get();
    DocumentSnapshot doc =await nurses.doc(nurseId).collection('rating').doc('rating').get();
    int rating = 0;
    int previousRating=0;
    if(x.exists){
      previousRating = int.parse(x['rating']);
      switch(previousRating){
        case 1:
          if(doc.exists&&doc['1'] != null){
            rating = int.parse(doc['1']);
          }
          rating =rating -1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '1': rating.toString()
          },SetOptions(merge: true));
          break;
        case 2:
          if(doc.exists&&doc['2'] != null){
            rating = int.parse(doc['2']);
          }
          rating =rating -1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '2': rating.toString()
          },SetOptions(merge: true));
          break;
        case 3:
          if(doc.exists&&doc['3'] != null){
            rating = int.parse(doc['3']);
          }
          rating =rating -1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '3': rating.toString()
          },SetOptions(merge: true));
          break;
        case 4:
          if(doc.exists&&doc['4'] != null){
            rating = int.parse(doc['4']);
          }
          rating =rating -1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '4': rating.toString()
          },SetOptions(merge: true));
          break;
        case 5:
          if(doc.exists&&doc['5'] != null){
            rating = int.parse(doc['5']);
          }
          rating =rating -1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '5': rating.toString()
          },SetOptions(merge: true));
          break;
      }
    }
      switch(ratingCount){
        case 1:
          if(doc.exists&&doc['1'] != null){
            rating = int.parse(doc['1']);
          }
          rating =rating +1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '1': rating.toString()
          },SetOptions(merge: true));
          break;
        case 2:
          if(doc.exists&&doc['2'] != null){
            rating = int.parse(doc['2']);
          }
          rating =rating +1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '2': rating.toString()
          },SetOptions(merge: true));
          break;
        case 3:
          if(doc.exists&&doc['3'] != null){
            rating = int.parse(doc['3']);
          }
          rating =rating +1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '3': rating.toString()
          },SetOptions(merge: true));
          break;
        case 4:
          if(doc.exists&&doc['4'] != null){
            rating = int.parse(doc['4']);
          }
          rating =rating +1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '4': rating.toString()
          },SetOptions(merge: true));
          break;
        case 5:
          if(doc.exists&&doc['5'] != null){
            rating = int.parse(doc['5']);
          }
          rating =rating +1;
          nurses.doc(nurseId).collection('rating').doc('rating').set({
            '5': rating.toString()
          },SetOptions(merge: true));
          break;
      }
    await patientCollection.doc(patientId).collection('rating').doc(nurseId).set({
      'rating': ratingCount.toString()
    },SetOptions(merge: true));
    DocumentSnapshot ratingNurse = await nurses.doc(nurseId).collection('rating').doc('rating').get();

    if(ratingNurse.exists) {
      int one = ratingNurse['1'] == null ? 0 : int.parse(ratingNurse['1']);
      int two = ratingNurse['2'] == null ? 0 : int.parse(ratingNurse['2']);
      int three = ratingNurse['3'] == null ? 0 : int.parse(ratingNurse['3']);
      int four = ratingNurse['4'] == null ? 0 : int.parse(ratingNurse['4']);
      int five = ratingNurse['5'] == null ? 0 : int.parse(ratingNurse['5']);
      totalRatingForNurse =
          (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
              (one + two + three + four + five);
      notifyListeners();
    }
  }

  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    return dist * 1.609344;
  }


  Future<UserData> getUserData({String type, String userId}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    UserData user;
    if (type == 'Patient' || type == 'مريض') {
      DocumentSnapshot doc = await patientCollection.doc(userId).get();
      if (doc.data != null) {
        user = UserData(
          specializationBranch: doc['specializationBranch'] ?? '',
          specialization: doc['specialization'] ?? '',
          name: doc['name'] ?? '',
          docId: doc.id ?? '',
          lat: doc['lat'] ?? '',
          lng: doc['lng'] ?? '',
          nationalId: doc['nationalId'] ?? '',
          gender: doc['gender'] ?? '',
          birthDate: doc['birthDate'] ?? '',
          address: doc['address'] ?? '',
          phoneNumber: doc['phoneNumber'] ?? '',
          imgUrl: doc['imgUrl'] ?? '',
          email: doc['email'] ?? '',
          aboutYou: doc['aboutYou'] ?? '',
          points: doc['points'] ?? '',
        );
      }
    } else {
      DocumentSnapshot doc = await nursesCollection.doc(userId).get();
      DocumentSnapshot rating = await nursesCollection.doc(userId).collection('rating').doc('rating').get();
      if(rating.exists) {
        int one = rating['1'] == null ? 0 : int.parse(rating['1']);
        int two = rating['2'] == null ? 0 : int.parse(rating['2']);
        int three = rating['3'] == null ? 0 : int.parse(rating['3']);
        int four = rating['4'] == null ? 0 : int.parse(rating['4']);
        int five = rating['5'] == null ? 0 : int.parse(rating['5']);
        totalRatingForNurse =
            (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                (one + two + three + four + five);
      }
      user = UserData(
        specializationBranch: doc['specializationBranch'] ?? '',
        specialization: doc['specialization'] ?? '',
        rating: totalRatingForNurse.toString(),
        name: doc['name'] ?? '',
        docId: doc.id ?? '',
        lat: doc['lat'] ?? '',
        lng: doc['lng'] ?? '',
        nationalId: doc['nationalId'] ?? '',
        gender: doc['gender'] ?? '',
        birthDate: doc['birthDate'] ?? '',
        address: doc['address'] ?? '',
        phoneNumber: doc['phoneNumber'] ?? '',
        imgUrl: doc['imgUrl'] ?? '',
        email: doc['email'] ?? '',
        aboutYou: doc['aboutYou'] ?? '',
        points: doc['points'] ?? '',
      );
    }
    return user;
  }

  Future getAllAcceptedRequests({String userId,String userLat='0.0',String userLong='0.0'}) async {
    var requests = databaseReference.collection('requests');
    QuerySnapshot docs =
        await requests.where('nurseId', isEqualTo: userId).get();
    double distance = 0.0;
    allAcceptedRequests.clear();
    print('A');
    if (docs.docs.length != 0) {
      print('B');
      String time='';
      String acceptTime=''; List<String> convertAllVisitsTime=[];
      for (int i = 0; i < docs.docs.length; i++) {
        distance = _calculateDistance(
           userLat != '0.0'? double.parse(userLat):0.0,
            userLong != '0.0'? double.parse(userLong):0.0,
            double.parse(docs.docs[i]['lat']??'0.0'),
            double.parse(docs.docs[i]['long']??'0.0'));
        print('distance::$distance');
          if(docs.docs[i]['time'] !=''){
            time=convertTimeToAMOrPM(time: docs.docs[i]['time']);
          }else{
            time='';
          }
          if(docs.docs[i]['acceptTime'] !=null&&docs.docs[i]['acceptTime'] !=''){
            acceptTime=convertTimeToAMOrPM(time: docs.docs[i]['acceptTime']);
          }else{
            acceptTime='';
          }
          if (docs.docs[i]['visitTime'] != '[]') {
            var x = docs.docs[i]['visitTime'].replaceFirst('[', '').toString();
            String visitTime = x.replaceAll(')', '');
            List<String> times=visitTime.split(',');
            if(times.length !=0){
              for(int i=0; i<times.length; i++){
                convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
              }
            }
          }else{
            convertAllVisitsTime=[];
          }
          allAcceptedRequests.add(Requests(
              specialization: docs.docs[i]['specialization'] ?? '',
              specializationBranch: docs.docs[i]['specializationBranch'] ?? '',
            distance:  distance.floor().toString(),
              lat:  docs.docs[i]['lat'] ?? '',
              long:  docs.docs[i]['long'] ?? '',
              acceptTime: acceptTime,
              nurseId: docs.docs[i]['nurseId'] ?? '',
              patientId: docs.docs[i]['patientId'] ?? '',
              docId: docs.docs[i].id,
              visitTime: convertAllVisitsTime.toString() == '[]'
                  ? ''
                  : convertAllVisitsTime.toString(),
              visitDays: docs.docs[i]['visitDays'] == '[]'
                  ? ''
                  : docs.docs[i]['visitDays'] ?? '',
              suppliesFromPharmacy:
              docs.docs[i]['suppliesFromPharmacy'] ?? '',
              startVisitDate: docs.docs[i]['startVisitDate'] ?? '',
              serviceType: docs.docs[i]['serviceType'] ?? '',
              picture: docs.docs[i]['picture'] ?? '',
              patientPhone: docs.docs[i]['patientPhone'] ?? '',
              patientName: docs.docs[i]['patientName'] ?? '',
              patientLocation: docs.docs[i]['patientLocation'] ?? '',
              patientGender: docs.docs[i]['patientGender'] ?? '',
              patientAge: docs.docs[i]['patientAge'] ?? '',
              servicePrice: docs.docs[i]['servicePrice'] ?? '',
              time: time,
              date: docs.docs[i]['date'] ?? '',
              discountPercentage:
              docs.docs[i]['discountPercentage'] ?? '',
              nurseGender: docs.docs[i]['nurseGender'] ?? '',
              numOfPatients: docs.docs[i]['numOfPatients'] ?? '',
              endVisitDate: docs.docs[i]['endVisitDate'] ?? '',
              discountCoupon: docs.docs[i]['discountCoupon'] ?? '',
              priceBeforeDiscount:
              docs.docs[i]['priceBeforeDiscount'] ?? '',
              analysisType: docs.docs[i]['analysisType'] ?? '',
              notes: docs.docs[i]['notes'] ?? '',
              priceAfterDiscount:
              docs.docs[i]['priceAfterDiscount'].toString() ?? ''));
        print('dfbfdsndd');
        print(allAcceptedRequests.length);
        }
    }
    notifyListeners();
  }

  Future getAllPatientRequests({String userId, String userType,String userLat='0.0',String userLong='0.0'}) async {
    if (userType == 'patient') {
      var requests = databaseReference.collection('requests');
      requests.where('patientId', isEqualTo: userId).snapshots().listen((docs) {
        print('A');
        if (docs.docs.length != 0) {
          print('B');
          double distance = 0.0;
          allPatientsRequests.clear();
          String time='';
          String acceptTime='';
          List<String> convertAllVisitsTime=[];
          for (int i = 0; i < docs.docs.length; i++) {
            distance = _calculateDistance(
                userLat != '0.0'? double.parse(userLat):0.0,
                userLong != '0.0'? double.parse(userLong):0.0,
                double.parse(docs.docs[i]['lat']??'0.0'),
                double.parse(docs.docs[i]['long']??'0.0'));
            print('distance::$distance');
            if(docs.docs[i]['time'] !=''){
              time=convertTimeToAMOrPM(time: docs.docs[i]['time']);
            }else{
              time='';
            }
            if(docs.docs[i]['acceptTime'] !=null&& docs.docs[i]['acceptTime'] !=''){
              acceptTime=convertTimeToAMOrPM(time: docs.docs[i]['acceptTime']);
            }else{
              acceptTime='';
            }

            if (docs.docs[i]['visitTime'] != '[]') {
              var x = docs.docs[i]['visitTime'].replaceFirst('[', '').toString();
              String visitTime = x.replaceAll(')', '');
              List<String> times=visitTime.trim().split(',');
                for(int j=0; j<times.length; j++){
                  print('times[j]:${times[j]}');
                  String result = convertTimeToAMOrPM(time: times[j]);
                  print('result:$result');
                  convertAllVisitsTime.add('$result');
                  print(convertAllVisitsTime);
                }
            }else{
              convertAllVisitsTime=[];
            }
            print('convertAllVisitsTime: $convertAllVisitsTime');
            allPatientsRequests.add(Requests(
                specialization: docs.docs[i]['specialization'] ?? '',
                specializationBranch: docs.docs[i]['specializationBranch'] ?? '',
                lat:  docs.docs[i]['lat'] ?? '',
                distance:  distance.floor().toString(),
                long:  docs.docs[i]['long'] ?? '',
                isFinished: docs.docs[i]['isFinished'] ?? false,
                acceptTime: acceptTime,
                nurseId: docs.docs[i]['nurseId'] ?? '',
                patientId: docs.docs[i]['patientId'] ?? '',
                docId: docs.docs[i].id,
                visitTime: convertAllVisitsTime.toString() == '[]'
                    ? ''
                    : convertAllVisitsTime.toString(),
                visitDays: docs.docs[i]['visitDays'] == '[]'
                    ? ''
                    : docs.docs[i]['visitDays'] ?? '',
                suppliesFromPharmacy:
                    docs.docs[i]['suppliesFromPharmacy'] ?? '',
                startVisitDate: docs.docs[i]['startVisitDate'] ?? '',
                serviceType: docs.docs[i]['serviceType'] ?? '',
                picture: docs.docs[i]['picture'] ?? '',
                patientPhone: docs.docs[i]['patientPhone'] ?? '',
                patientName: docs.docs[i]['patientName'] ?? '',
                patientLocation:
                    docs.docs[i]['patientLocation'] ?? '',
                patientGender: docs.docs[i]['patientGender'] ?? '',
                patientAge: docs.docs[i]['patientAge'] ?? '',
                servicePrice: docs.docs[i]['servicePrice'] ?? '',
                time: time,
                date: docs.docs[i]['date'] ?? '',
                discountPercentage:
                    docs.docs[i]['discountPercentage'] ?? '',
                nurseGender: docs.docs[i]['nurseGender'] ?? '',
                numOfPatients: docs.docs[i]['numOfPatients'] ?? '',
                endVisitDate: docs.docs[i]['endVisitDate'] ?? '',
                discountCoupon: docs.docs[i]['discountCoupon'] ?? '',
                priceBeforeDiscount:
                    docs.docs[i]['priceBeforeDiscount'] ?? '',
                analysisType: docs.docs[i]['analysisType'] ?? '',
                notes: docs.docs[i]['notes'] ?? '',
                priceAfterDiscount:
                    docs.docs[i]['priceAfterDiscount'].toString() ??
                        ''));
          }
          print(allPatientsRequests.length);
        } else {
          allPatientsRequests.clear();
        }
        notifyListeners();
      });
    }
  }

  Future getAllArchivedRequests({String userId}) async {
    var requests = databaseReference
        .collection('users')
        .doc(userId)
        .collection('archived requests');
    QuerySnapshot docs = await requests.get();
    allArchivedRequests.clear();
    print('A');
    if (docs.docs.length != 0) {
      print('B');
      String time='';
      String acceptTime=''; List<String> convertAllVisitsTime=[];
      for (int i = 0; i < docs.docs.length; i++) {
        if(docs.docs[i]['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.docs[i]['time']);
        }else{
          time='';
        }
        if(docs.docs[i]['acceptTime'] !=null &&docs.docs[i]['acceptTime'] !=''){
          acceptTime=convertTimeToAMOrPM(time: docs.docs[i]['acceptTime']);
        }else{
          acceptTime='';
        }

        if (docs.docs[i]['visitTime'] != '[]') {
          var x = docs.docs[i]['visitTime'].replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(')', '');
          List<String> times=visitTime.split(',');
          if(times.length !=0){
            for(int i=0; i<times.length; i++){
              convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
            }
          }
        }else{
          convertAllVisitsTime=[];
        }
        allArchivedRequests.add(Requests(
            specialization: docs.docs[i]['specialization'] ?? '',
            specializationBranch: docs.docs[i]['specializationBranch'] ?? '',
            acceptTime: acceptTime,
            lat:  docs.docs[i]['lat'] ?? '',
            long:  docs.docs[i]['long'] ?? '',
            nurseId: docs.docs[i]['nurseId'] ?? '',
            patientId: docs.docs[i]['patientId'] ?? '',
            docId: docs.docs[i].id,
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),
            visitDays: docs.docs[i]['visitDays'] == '[]'
                ? ''
                : docs.docs[i]['visitDays'] ?? '',
            suppliesFromPharmacy:
                docs.docs[i]['suppliesFromPharmacy'] ?? '',
            startVisitDate: docs.docs[i]['startVisitDate'] ?? '',
            serviceType: docs.docs[i]['serviceType'] ?? '',
            picture: docs.docs[i]['picture'] ?? '',
            patientPhone: docs.docs[i]['patientPhone'] ?? '',
            patientName: docs.docs[i]['patientName'] ?? '',
            patientLocation: docs.docs[i]['patientLocation'] ?? '',
            patientGender: docs.docs[i]['patientGender'] ?? '',
            patientAge: docs.docs[i]['patientAge'] ?? '',
            servicePrice: docs.docs[i]['servicePrice'] ?? '',
            time: time,
            date: docs.docs[i]['date'] ?? '',
            discountPercentage:
                docs.docs[i]['discountPercentage'] ?? '',
            nurseGender: docs.docs[i]['nurseGender'] ?? '',
            numOfPatients: docs.docs[i]['numOfPatients'] ?? '',
            endVisitDate: docs.docs[i]['endVisitDate'] ?? '',
            discountCoupon: docs.docs[i]['discountCoupon'] ?? '',
            priceBeforeDiscount:
                docs.docs[i]['priceBeforeDiscount'] ?? '',
            analysisType: docs.docs[i]['analysisType'] ?? '',
            notes: docs.docs[i]['notes'] ?? '',
            priceAfterDiscount:
                docs.docs[i]['priceAfterDiscount'].toString() ?? ''));
      }
      print('dfbfdsndd');
      print(allArchivedRequests.length);
      notifyListeners();
    }
  }

  Future getNurseSupplies({String userId}) async {
    var supplies = databaseReference.collection("nurses").doc(userId);
    var docs = await supplies.collection('supplying').get();
    if (docs.docs.length != 0) {
      allNurseSupplies.clear();
      String time='';
      for (int i = 0; i < docs.docs.length; i++) {

        if(docs.docs[i]['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.docs[i]['time']);
        }else{
          time='';
        }
        allNurseSupplies.add(Supplying(
            points: docs.docs[i]['points'] ?? '',
            date: docs.docs[i]['date'] ?? '',
            time: time));
      }
    }
    notifyListeners();
  }

  Future<bool> addRequest(
      {String analysisType,
      String patientId,
        String specialization='',String specializationBranch='',
      String patientName,
      String patientPhone,
      String patientLocation,
      String patientLat,
      String patientLong,
      String patientAge,
      String patientGender,
      String numOfPatients,
      String serviceType,
      String nurseGender,
      String suppliesFromPharmacy,
      File picture,
      String discountCoupon,
      String startVisitDate,
      String endVisitDate,
      String visitDays,
      String visitTime,
      String notes}) async {
    String imgUrl = '';
    var users = databaseReference.collection("users");
    var _coupons = databaseReference.collection("coupons");
    if (picture != null) {
      try {
        var storageReference = FirebaseStorage.instance.ref().child(
            '$serviceType/$patientName/$patientPhone/${path.basename(picture.path)}');
        var uploadTask = storageReference.putFile(picture);
        await uploadTask;
        await storageReference.getDownloadURL().then((fileURL) async {
          imgUrl = fileURL;
        });
      } catch (e) {
        print(e);
      }
    }
    DateTime dateTime = DateTime.now();

    DocumentReference x = await databaseReference.collection('requests').add({
      'nurseId': '',
      'patientId': patientId ?? '',
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientLocation': patientLocation,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'numOfPatients': numOfPatients,
      'serviceType': serviceType,
      'analysisType': analysisType,
      'nurseGender': nurseGender,
      'lat':patientLat,
      'specialization':specialization,
      'specializationBranch':specializationBranch,
      'long':patientLong,
      'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
      'time': '${dateTime.hour}:${dateTime.minute}',
      'servicePrice': discountCoupon == ''
          ? price.servicePrice.toString()
          : priceBeforeDiscount.toString(),
      'suppliesFromPharmacy': suppliesFromPharmacy,
      'picture': imgUrl,
      'discountPercentage': coupon.discountPercentage,
      'discountCoupon': discountCoupon,
      'startVisitDate': startVisitDate,
      'endVisitDate': endVisitDate,
      'visitDays': visitDays,
      'visitTime': visitTime,
      'notes': notes,
      'priceBeforeDiscount': discountCoupon == ''
          ? price.servicePrice.toString()
          : priceBeforeDiscount.toString(),
      'priceAfterDiscount': price.servicePrice,
    });

    await users
        .doc(patientId)
        .collection('requests')
        .doc(x.id)
        .set({'docId': x.id});
    if (coupon.docId != '') {
      int x = int.parse(coupon.numberOfUses);
      if (x != 0) {
        x = x - 1;
      }
      _coupons.doc(coupon.docId).update({
        'numberOfUses': x.toString(),
      });
      await users
          .doc(patientId)
          .collection('coupons')
          .doc(coupon.docId)
          .set({'couponName': coupon.couponName});
    }
    return true;
  }
  Future<bool> editRequest(
      {String docId,
        bool isPictureTypeFile=true,
      String analysisType,
        String specialization='',String specializationBranch='',
      String patientId,
      String patientName,
      String patientPhone,
      String patientLocation,
      String patientLat,
      String patientLong,
      String patientAge,
      String patientGender,
      String numOfPatients,
      String serviceType,
      String nurseGender,
      String suppliesFromPharmacy,
      dynamic picture,
      String discountCoupon,
      String startVisitDate,
      String endVisitDate,
      String visitDays,
      String visitTime,
      String notes}) async {
    String imgUrl = '';
    var users = databaseReference.collection("users");
    var _coupons = databaseReference.collection("coupons");

      if (isPictureTypeFile == true && picture != null) {
        try {
          var storageReference = FirebaseStorage.instance.ref().child(
              '$serviceType/$patientName/$patientPhone/${path.basename(
                  picture.path)}');
          var uploadTask = storageReference.putFile(picture);
          await uploadTask;
          await storageReference.getDownloadURL().then((fileURL) async {
            imgUrl = fileURL;
          });
        } catch (e) {
          print(e);
        }
      }
      DateTime dateTime = DateTime.now();
      await databaseReference.collection('requests').doc(docId).set({
        'nurseId': '',
        'patientId': patientId ?? '',
        'patientName': patientName,
        'patientPhone': patientPhone,
        'patientLocation': patientLocation,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'numOfPatients': numOfPatients,
        'serviceType': serviceType,
        'analysisType': analysisType,
        'nurseGender': nurseGender,
        'specialization':specialization,
        'specializationBranch':specializationBranch,
        'lat': patientLat,
        'long': patientLong,
        'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        'time': '${dateTime.hour}:${dateTime.minute}',
        'servicePrice': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'suppliesFromPharmacy': suppliesFromPharmacy,
        'picture': isPictureTypeFile == true ? imgUrl : picture,
        'discountPercentage': coupon.discountPercentage,
        'discountCoupon': discountCoupon,
        'startVisitDate': startVisitDate,
        'endVisitDate': endVisitDate,
        'visitDays': visitDays,
        'visitTime': visitTime,
        'notes': notes,
        'priceBeforeDiscount': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'priceAfterDiscount': price.servicePrice,
      }, SetOptions(merge: true));


      if (coupon.docId != '') {
        int x = int.parse(coupon.numberOfUses);
        if (x != 0) {
          x = x - 1;
        }
        _coupons.doc(coupon.docId).update({
          'numberOfUses': x.toString(),
        });
        await users
            .doc(patientId)
            .collection('coupons')
            .doc(coupon.docId)
            .set({'couponName': coupon.couponName});
      }
      return true;
  }

  Future<bool> endRequest({Requests request, UserData userData}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
//    var x =await  patientCollection.doc(request.patientId).get();
//    if(x.exists){
//      int points = int.parse(x['points')?? '0');
//      double point = double.parse(request.priceAfterDiscount);
//      if(points >= point.floor()){
//        int result = points - point.floor();
//        patientCollection.doc(request.patientId).update({
//          'points': result
//        });
//      }
//    }
    CollectionReference allRequests = databaseReference.collection('requests');
    CollectionReference archived =
        databaseReference.collection('archived requests');
    CollectionReference archivedForPatients =
        databaseReference.collection('archivedForPatients');
    DocumentSnapshot getPoints=await nursesCollection
        .doc(userData.docId).get();
    int points = int.parse(getPoints['points']);
    print('request.priceAfterDiscount');
    print(request.priceAfterDiscount);
    double priceAfterDiscount=double.parse(request.priceAfterDiscount);
    points = points + priceAfterDiscount.floor();
    await nursesCollection
        .doc(userData.docId)
        .update({'points': points.toString()});
    DateTime dateTime = DateTime.now();
    await nursesCollection
        .doc(userData.docId)
        .collection('archived requests')
        .doc(request.docId)
        .set({
      'serviceType': request.serviceType,
      'analysisType': request.analysisType,
      'points': request.priceAfterDiscount,
      'date': '${dateTime.year}-${dateTime.month}-${dateTime.day}',
      'time': '${dateTime.hour}:${dateTime.minute}',
    });

    String acceptTime='';
    String time=''; List<String> convertAllVisitsTime=[];
    if(acceptTime !=''){
      acceptTime = convertTimeTo24Hour(time: request.acceptTime);
    }
    if(request.time !=''){
      time = convertTimeTo24Hour(time: request.time);
    }

    if (request.visitTime != '[]') {
      var x = request.visitTime.replaceFirst('[', '').toString();
      String visitTime = x.replaceAll(')', '');
      List<String> times=visitTime.split(',');
      if(times.length !=0){
        for(int i=0; i<times.length; i++){
          convertAllVisitsTime.add(convertTimeTo24Hour(time: times[i]));
        }
      }
    }else{
      convertAllVisitsTime=[];
    }
    await allRequests.doc(request.docId).delete();
    if (request.patientId != '') {
      await patientCollection
          .doc(request.patientId)
          .collection('archived requests')
          .doc(request.docId)
          .set({
      'specialization':request.specialization,
      'specializationBranch':request.specializationBranch,
        'acceptTime':acceptTime,
        'nurseId': userData.docId,
        'patientId': request.patientId,
        'patientName': request.patientName,
        'patientPhone': request.patientPhone,
        'patientLocation': request.patientLocation,
        'patientAge': request.patientAge,
        'lat':request.lat,
        'long':request.long,
        'patientGender': request.patientGender,
        'numOfPatients': request.numOfPatients,
        'serviceType': request.serviceType,
        'analysisType': request.analysisType,
        'nurseGender': request.nurseGender,
        'date': request.date,
        'time':time,
        'servicePrice': request.servicePrice,
        'suppliesFromPharmacy': request.suppliesFromPharmacy,
        'picture': request.picture,
        'discountPercentage': request.discountPercentage,
        'discountCoupon': request.discountCoupon,
        'startVisitDate': request.startVisitDate,
        'endVisitDate': request.endVisitDate,
        'visitDays': request.visitDays,
        'visitTime': convertAllVisitsTime.toString(),
        'notes': request.notes,
        'priceBeforeDiscount': request.priceBeforeDiscount,
        'priceAfterDiscount': request.priceAfterDiscount,
      });
      archivedForPatients.doc(request.docId)
          .set({
        'patientId':request.patientId
      });
    } else {
      await archived.doc(request.docId).set({
        'specialization':request.specialization,
        'specializationBranch':request.specializationBranch,
        'nurseId': userData.docId,
        'patientId': request.patientId,
        'patientName': request.patientName,
        'acceptTime':acceptTime,
        'patientPhone': request.patientPhone,
        'patientLocation': request.patientLocation,
        'patientAge': request.patientAge,
        'lat':request.lat,
        'long':request.long,
        'patientGender': request.patientGender,
        'numOfPatients': request.numOfPatients,
        'serviceType': request.serviceType,
        'analysisType': request.analysisType,
        'nurseGender': request.nurseGender,
        'date': request.date,
        'time':time,
        'servicePrice': request.servicePrice,
        'suppliesFromPharmacy': request.suppliesFromPharmacy,
        'picture': request.picture,
        'discountPercentage': request.discountPercentage,
        'discountCoupon': request.discountCoupon,
        'startVisitDate': request.startVisitDate,
        'endVisitDate': request.endVisitDate,
        'visitDays': request.visitDays,
        'visitTime': convertAllVisitsTime.toString(),
        'notes': request.notes,
        'priceBeforeDiscount': request.priceBeforeDiscount,
        'priceAfterDiscount': request.priceAfterDiscount,
      });
    }

    allPatientsRequests.removeWhere((x) => x.docId == request.docId);
    allAcceptedRequests.removeWhere((x) => x.docId == request.docId);
    userData.points = points.toString();
    notifyListeners();
    return true;
  }

  Future<bool> sendRequestToFinish({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    await allRequests.doc(requestId).set({'isFinished': true}, SetOptions(merge: true));
    return true;
  }

  Future<bool> sendRequestToCancel({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    await allRequests.doc(requestId).update({'isFinished': false});
    return true;
  }

  Future<bool> cancelRequest({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    allRequests.doc(requestId).update({'nurseId': '','acceptTime':null,});
    allAcceptedRequests.removeWhere((x)=>x.docId==requestId);
    notifyListeners();
    return true;
  }

  Future<String> verifyCoupon({String userId,String couponName}) async {
    CollectionReference services = databaseReference.collection("coupons");
    CollectionReference users = databaseReference.collection("users");
    QuerySnapshot isUsedBefore=await users
        .doc(userId)
        .collection('coupons').where('couponName', isEqualTo: couponName).get();
    if(isUsedBefore.docs.length != 0){
      return 'isUserBefore';
    }else{

      QuerySnapshot docs = await services
          .where('couponName', isEqualTo: couponName.trim())
          .get();
      if (docs.docs.length == 0) {
        return 'false';
      } else {
        List<String> date =
        docs.docs[0]['expiryDate'].toString().split('-');
        print(date);
        DateTime time =
        DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
        if (price.isAddingDiscount == false &&
            price.servicePrice != 0.0 &&
            docs.docs[0]['numberOfUses'].toString() != '0' &&
            time.isAfter(DateTime.now())) {
          coupon = Coupon(
            docId: docs.docs[0].id,
            couponName: docs.docs[0]['couponName'],
            discountPercentage: docs.docs[0]['discountPercentage'],
            expiryDate: docs.docs[0]['expiryDate'],
            numberOfUses: docs.docs[0]['numberOfUses'].toString(),
          );
          double prices = price.servicePrice;
          priceBeforeDiscount = price.servicePrice;
          discount = prices * (double.parse(coupon.discountPercentage) / 100);
          List<String> x = price.allServiceType;
          price = Price(
              servicePrice: (prices - discount),
              isAddingDiscount: true,
              allServiceType: x);
          notifyListeners();
          return 'true';
        } else if (price.servicePrice == 0.0) {
          return 'add service before discount';
        } else if (!time.isAfter(DateTime.now()) ||
            docs.docs[0]['numberOfUses'] == '0') {
          return 'Coupon not Avilable';
        } else {
          return 'already discount';
        }
      }
    }
  }



  Future<bool> deleteRequest({String patientId,Requests request}) async {
    var requests = databaseReference.collection("requests");
    await requests.doc(request.docId).delete();

    if (request.discountCoupon != '') {
      CollectionReference users = databaseReference.collection("users");
      CollectionReference _coupons = databaseReference.collection("coupons");
      QuerySnapshot docs = await _coupons
          .where('couponName', isEqualTo: request.discountCoupon)
          .get();
      if (docs.docs.length != 0) {
        int x = int.parse(docs.docs[0]['numberOfUses']);
        x = x + 1;
        await _coupons.doc(docs.docs[0].id).update({
          'numberOfUses': x.toString(),
        });
          await users
              .doc(patientId)
              .collection('coupons')
              .doc(docs.docs[0].id)
              .delete();
      }
    }
    allPatientsRequests.removeWhere((x) => x.docId == request.docId);
    notifyListeners();
    return true;
  }

  Future<bool> acceptRequest({Requests request, UserData userData}) async {
    DateTime dateTime = DateTime.now();
    CollectionReference requests = databaseReference.collection('requests');
    requests.doc(request.docId).update({
      'nurseId': userData.docId,
      'acceptTime': '${dateTime.hour}:${dateTime.minute}',
    });
    allPatientsRequests.removeWhere((x) => x.docId == request.docId);
    request.nurseId = userData.docId;
    allAcceptedRequests.add(request);
//    getAllCompletedRequests(userId: userData.docId);
    return true;
  }

  String convertTimeToAMOrPM({String time}) {
    List<String> split = time.split(':');
    int clock = int.parse(split[0]);
    String realTime = '';
    print('clock: $clock');
      switch (clock) {
        case 13:
          realTime = translator.activeLanguageCode == 'en'
              ? '1:${split[1]} PM'
              : '1:${split[1]} م ';
          break;
        case 14:
          realTime = translator.activeLanguageCode == 'en'
              ? '2:${split[1]} PM'
              : '2:${split[1]} م ';
          break;
        case 15:
          realTime = translator.activeLanguageCode == 'en'
              ? '3:${split[1]} PM'
              : '3:${split[1]} م ';
          break;
        case 16:
          realTime = translator.activeLanguageCode == 'en'
              ? '4:${split[1]} PM'
              : '4:${split[1]} م ';
          break;
        case 17:
          realTime = translator.activeLanguageCode == 'en'
              ? '5:${split[1]} PM'
              : '5:${split[1]} م ';
          break;
        case 18:
          realTime = translator.activeLanguageCode == 'en'
              ? '6:${split[1]} PM'
              : '6:${split[1]} م ';
          break;
        case 19:
          realTime = translator.activeLanguageCode == 'en'
              ? '7:${split[1]} PM'
              : '7:${split[1]} م ';
          break;
        case 20:
          realTime = translator.activeLanguageCode == 'en'
              ? '8:${split[1]} PM'
              : '8:${split[1]} م ';
          break;
        case 21:
          realTime = translator.activeLanguageCode == 'en'
              ? '9:${split[1]} PM'
              : '9:${split[1]} م ';
          break;
        case 22:
          realTime = translator.activeLanguageCode == 'en'
              ? '10:${split[1]} PM'
              : '10:${split[1]} م ';
          break;
        case 23:
          realTime = translator.activeLanguageCode == 'en'
              ? '11:${split[1]} PM'
              : '11:${split[1]} م ';
          break;
        case 00:
        case 0:
          realTime = translator.activeLanguageCode == 'en'
              ? '12:${split[1]} PM'
              : '12:${split[1]} م ';
          break;
        case 01:
          realTime = translator.activeLanguageCode == 'en'
              ? '1:${split[1]} AM'
              : '1:${split[1]} ص ';
          break;
        case 02:
          realTime = translator.activeLanguageCode == 'en'
              ? '2:${split[1]} AM'
              : '2:${split[1]} ص ';
          break;
        case 03:
          realTime = translator.activeLanguageCode == 'en'
              ? '3:${split[1]} AM'
              : '3:${split[1]} ص ';
          break;
        case 04:
          realTime = translator.activeLanguageCode == 'en'
              ? '4:${split[1]} AM'
              : '4:${split[1]} ص ';
          break;
        case 05:
          realTime = translator.activeLanguageCode == 'en'
              ? '5:${split[1]} AM'
              : '5:${split[1]} ص ';
          break;
        case 06:
          realTime = translator.activeLanguageCode == 'en'
              ? '6:${split[1]} AM'
              : '6:${split[1]} ص ';
          break;
        case 07:
          realTime = translator.activeLanguageCode == 'en'
              ? '7:${split[1]} AM'
              : '7:${split[1]} ص ';
          break;
        case 08:
          realTime = translator.activeLanguageCode == 'en'
              ? '8:${split[1]} AM'
              : '8:${split[1]} ص ';
          break;
        case 09:
          realTime = translator.activeLanguageCode == 'en'
              ? '9:${split[1]} AM'
              : '9:${split[1]} ص ';
          break;
        case 10:
          realTime = translator.activeLanguageCode == 'en'
              ? '10:${split[1]} AM'
              : '10:${split[1]} ص ';
          break;
        case 11:
          realTime = translator.activeLanguageCode == 'en'
              ? '11:${split[1]} AM'
              : '11:${split[1]} ص ';
          break;
        case 12:
          realTime = translator.activeLanguageCode == 'en'
              ? '12:${split[1]} AM':'12:${split[1]} ص ';
          break;
      }
    return realTime;
  }
  String convertTimeTo24Hour({String time}){
    String realTime = '';
    print('time: $time');

    if(translator.activeLanguageCode == 'en'){
      if(time.contains('AM')){
        String splitter = time.replaceAll('AM','').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch(int.parse(splitTime[0])){
          case 1:
            realTime = '01:${ splitTime[1]}';
            break;
          case 2:
            realTime = '02:${ splitTime[1]}';
            break;
          case 3:
            realTime = '03:${ splitTime[1]}';
            break;
          case 4:
            realTime = '04:${ splitTime[1]}';
            break;
          case 5:
            realTime = '05:${ splitTime[1]}';
            break;
          case 6:
            realTime = '06:${ splitTime[1]}';
            break;
          case 7:
            realTime = '07:${ splitTime[1]}';
            break;
          case 8:
            realTime = '08:${ splitTime[1]}';
            break;
          case 9:
            realTime = '09:${ splitTime[1]}';
            break;
          case 10:
            realTime = '10:${ splitTime[1]}';
            break;
          case 11:
            realTime = '11:${ splitTime[1]}';
            break;
          case 12:
            realTime = '12:${ splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
      if(time.contains('PM')){
        String splitter = time.replaceAll('PM','').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch(int.parse(splitTime[0])){
          case 1:
            realTime = '13:${ splitTime[1]}';
            break;
          case 2:
            realTime = '14:${ splitTime[1]}';
            break;
          case 3:
            realTime = '15:${ splitTime[1]}';
            break;
          case 4:
            realTime = '16:${ splitTime[1]}';
            break;
          case 5:
            realTime = '17:${ splitTime[1]}';
            break;
          case 6:
            realTime = '18:${ splitTime[1]}';
            break;
          case 7:
            realTime = '19:${ splitTime[1]}';
            break;
          case 8:
            realTime = '20:${ splitTime[1]}';
            break;
          case 9:
            realTime = '21:${ splitTime[1]}';
            break;
          case 10:
            realTime = '22:${ splitTime[1]}';
            break;
          case 11:
            realTime = '23:${ splitTime[1]}';
            break;
          case 12:
            realTime = '00:${ splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
    }else{
      if(time.contains('ص')){
        String splitter = time.replaceAll('ص','').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch(int.parse(splitTime[0])){
          case 1:
            realTime = '01:${ splitTime[1]}';
            break;
          case 2:
            realTime = '02:${ splitTime[1]}';
            break;
          case 3:
            realTime = '03:${ splitTime[1]}';
            break;
          case 4:
            realTime = '04:${ splitTime[1]}';
            break;
          case 5:
            realTime = '05:${ splitTime[1]}';
            break;
          case 6:
            realTime = '06:${ splitTime[1]}';
            break;
          case 7:
            realTime = '07:${ splitTime[1]}';
            break;
          case 8:
            realTime = '08:${ splitTime[1]}';
            break;
          case 9:
            realTime = '09:${ splitTime[1]}';
            break;
          case 10:
            realTime = '10:${ splitTime[1]}';
            break;
          case 11:
            realTime = '11:${ splitTime[1]}';
            break;
          case 12:
            realTime = '12:${ splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
      if(time.contains('م')){
        String splitter = time.replaceAll('م','').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch(int.parse(splitTime[0])){
          case 1:
            realTime = '13:${ splitTime[1]}';
            break;
          case 2:
            realTime = '14:${ splitTime[1]}';
            break;
          case 3:
            realTime = '15:${ splitTime[1]}';
            break;
          case 4:
            realTime = '16:${ splitTime[1]}';
            break;
          case 5:
            realTime = '17:${ splitTime[1]}';
            break;
          case 6:
            realTime = '18:${ splitTime[1]}';
            break;
          case 7:
            realTime = '19:${ splitTime[1]}';
            break;
          case 8:
            realTime = '20:${ splitTime[1]}';
            break;
          case 9:
            realTime = '21:${ splitTime[1]}';
            break;
          case 10:
            realTime = '22:${ splitTime[1]}';
            break;
          case 11:
            realTime = '23:${ splitTime[1]}';
            break;
          case 12:
            realTime = '00:${ splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
    }
    return realTime;
  }

  Future getAllCompletedRequests({String userId}) async {
    var completed =
        databaseReference.collection("nurses/$userId/archived requests");
    var docs = await completed.get();
    if (docs.docs.length != 0) {
      allCompleteRequests.clear();
      String time='';
      for (int i = 0; i < docs.docs.length; i++) {
        if(docs.docs[i]['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.docs[i]['time']);
        }else{
          time='';
        }
        allCompleteRequests.add(CompleteRequest(
          docId: docs.docs[i].id,
          date: docs.docs[i]['date'] ?? '',
          time: time,
          points: docs.docs[i]['points'] ?? '',
          analysisType: docs.docs[i]['analysisType']?? '',
          serviceType: docs.docs[i]['serviceType'] ?? '',
        ));
      }
    }
    notifyListeners();
  }
}
