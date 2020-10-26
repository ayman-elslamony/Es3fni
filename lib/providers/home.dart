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
  final databaseReference = Firestore.instance;
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
      translator.currentLanguage == "en" ? ['Analysis'] : ['تحاليل'];
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

  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.getDocuments();
    allService.clear();
    allServicesType =
        translator.currentLanguage == "en" ? ['Analysis'] : ['تحاليل'];
    if (docs.documents.length != 0) {
      for (int i = 0; i < docs.documents.length; i++) {
        allService.add(Service(
          id: docs.documents[i].documentID,
          price: docs.documents[i].data['price'],
          serviceName: docs.documents[i].data['serviceName'],
        ));
        allServicesType.add(docs.documents[i].data['serviceName']);
      }
    }
    notifyListeners();
  }

  Future getAllAnalysis() async {
    var analysis = databaseReference.collection("analysis");
    var docs = await analysis.getDocuments();
    if (docs.documents.length != 0) {
      allAnalysis.clear();
      allAnalysisType.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allAnalysis.add(Analysis(
          id: docs.documents[i].documentID,
          price: docs.documents[i].data['price'],
          analysisName: docs.documents[i].data['analysisName'],
        ));
        allAnalysisType.add(docs.documents[i].data['analysisName']);
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
      print(docs.documents);
      allPatientsRequests.clear();
      double distance = 0.0;
      print('A');
      if (docs.documents.length != 0) {
        print('B');
        String time = '';
        String acceptTime = '';
        List<String> convertAllVisitsTime = [];
        for (int i = 0; i < docs.documents.length; i++) {
          print('userlat:$lat');
          print('lat:${docs.documents[i].data['lat']}');
          print('userlng:$long');
          print('lng:${docs.documents[i].data['long']}');
          distance = _calculateDistance(
              lat != '0.0' ? double.parse(lat) : 0.0,
              long != '0.0' ? double.parse(long) : 0.0,
              double.parse(docs.documents[i].data['lat']??'0.0'),
              double.parse(docs.documents[i].data['long']??'0.0'));
          print('distance::$distance');

          if (distance <= radiusForAllRequests) {
            if (docs.documents[i].data['time'] != '') {
              time = convertTimeToAMOrPM(time: docs.documents[i].data['time']);
            } else {
              time = '';
            }
            if (docs.documents[i].data['acceptTime'] != null&&docs.documents[i].data['acceptTime'] != '') {
              acceptTime = convertTimeToAMOrPM(
                  time: docs.documents[i].data['acceptTime']);
            } else {
              acceptTime = '';
            }
            if (docs.documents[i].data['visitTime'] != '[]') {
              var x = docs.documents[i].data['visitTime']
                  .replaceFirst('[', '')
                  .toString();
              String visitTime = x.replaceAll(']', '');
              List<String> times = visitTime.split(',');
              if (times.length != 0) {
                for (int i = 0; i < times.length; i++) {
                  convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
                }
              }
            } else {
              convertAllVisitsTime = [];
            }
            allPatientsRequests.add(Requests(
                specialization: docs.documents[i].data['specialization'] ?? '',
                specializationBranch: docs.documents[i].data['specializationBranch'] ?? '',
                distance:  distance.floor().toString(),
                lat: docs.documents[i].data['lat'] ?? '',
                long: docs.documents[i].data['long'] ?? '',
                acceptTime: acceptTime,
                nurseId: docs.documents[i].data['nurseId'] ?? '',
                patientId: docs.documents[i].data['patientId'] ?? '',
                docId: docs.documents[i].documentID,
                visitTime: convertAllVisitsTime.toString() == '[]'
                    ? ''
                    : convertAllVisitsTime.toString(),
                visitDays: docs.documents[i].data['visitDays'] == '[]'
                    ? ''
                    : docs.documents[i].data['visitDays'] ?? '',
                suppliesFromPharmacy:
                docs.documents[i].data['suppliesFromPharmacy'] ?? '',
                startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
                serviceType: docs.documents[i].data['serviceType'] ?? '',
                picture: docs.documents[i].data['picture'] ?? '',
                patientPhone: docs.documents[i].data['patientPhone'] ?? '',
                patientName: docs.documents[i].data['patientName'] ?? '',
                patientLocation: docs.documents[i].data['patientLocation'] ??
                    '',
                patientGender: docs.documents[i].data['patientGender'] ?? '',
                patientAge: docs.documents[i].data['patientAge'] ?? '',
                servicePrice: docs.documents[i].data['servicePrice'] ?? '',
                time: time,
                date: docs.documents[i].data['date'] ?? '',
                discountPercentage:
                docs.documents[i].data['discountPercentage'] ?? '',
                nurseGender: docs.documents[i].data['nurseGender'] ?? '',
                numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
                endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
                discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
                priceBeforeDiscount:
                docs.documents[i].data['priceBeforeDiscount'] ?? '',
                analysisType: docs.documents[i].data['analysisType'] ?? '',
                notes: docs.documents[i].data['notes'] ?? '',
                priceAfterDiscount:
                docs.documents[i].data['priceAfterDiscount'].toString() ??
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
  DocumentSnapshot x = await patientCollection.document(patientId).collection('rating').document(nurseId).get();
    if(x.exists){
      rating = double.parse(x.data['rating']);
    }
   return rating;
}
  Future<void> ratingNurse({int ratingCount,String nurseId,String patientId})async{
    CollectionReference nurses= databaseReference.collection("nurses");
    CollectionReference patientCollection = databaseReference.collection("users");
    DocumentSnapshot x = await patientCollection.document(patientId).collection('rating').document(nurseId).get();
    DocumentSnapshot doc =await nurses.document(nurseId).collection('rating').document('rating').get();
    int rating = 0;
    int previousRating=0;
    if(x.exists){
      previousRating = int.parse(x.data['rating']);
      switch(previousRating){
        case 1:
          if(doc.exists&&doc.data['1'] != null){
            rating = int.parse(doc.data['1']);
          }
          rating =rating -1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '1': rating.toString()
          },merge: true);
          break;
        case 2:
          if(doc.exists&&doc.data['2'] != null){
            rating = int.parse(doc.data['2']);
          }
          rating =rating -1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '2': rating.toString()
          },merge: true);
          break;
        case 3:
          if(doc.exists&&doc.data['3'] != null){
            rating = int.parse(doc.data['3']);
          }
          rating =rating -1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '3': rating.toString()
          },merge: true);
          break;
        case 4:
          if(doc.exists&&doc.data['4'] != null){
            rating = int.parse(doc.data['4']);
          }
          rating =rating -1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '4': rating.toString()
          },merge: true);
          break;
        case 5:
          if(doc.exists&&doc.data['5'] != null){
            rating = int.parse(doc.data['5']);
          }
          rating =rating -1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '5': rating.toString()
          },merge: true);
          break;
      }
    }
      switch(ratingCount){
        case 1:
          if(doc.exists&&doc.data['1'] != null){
            rating = int.parse(doc.data['1']);
          }
          rating =rating +1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '1': rating.toString()
          },merge: true);
          break;
        case 2:
          if(doc.exists&&doc.data['2'] != null){
            rating = int.parse(doc.data['2']);
          }
          rating =rating +1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '2': rating.toString()
          },merge: true);
          break;
        case 3:
          if(doc.exists&&doc.data['3'] != null){
            rating = int.parse(doc.data['3']);
          }
          rating =rating +1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '3': rating.toString()
          },merge: true);
          break;
        case 4:
          if(doc.exists&&doc.data['4'] != null){
            rating = int.parse(doc.data['4']);
          }
          rating =rating +1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '4': rating.toString()
          },merge: true);
          break;
        case 5:
          if(doc.exists&&doc.data['5'] != null){
            rating = int.parse(doc.data['5']);
          }
          rating =rating +1;
          nurses.document(nurseId).collection('rating').document('rating').setData({
            '5': rating.toString()
          },merge: true);
          break;
      }
    await patientCollection.document(patientId).collection('rating').document(nurseId).setData({
      'rating': ratingCount.toString()
    },merge: true);
    DocumentSnapshot ratingNurse = await nurses.document(nurseId).collection('rating').document('rating').get();

    if(ratingNurse.exists) {
      int one = ratingNurse.data['1'] == null ? 0 : int.parse(ratingNurse.data['1']);
      int two = ratingNurse.data['2'] == null ? 0 : int.parse(ratingNurse.data['2']);
      int three = ratingNurse.data['3'] == null ? 0 : int.parse(ratingNurse.data['3']);
      int four = ratingNurse.data['4'] == null ? 0 : int.parse(ratingNurse.data['4']);
      int five = ratingNurse.data['5'] == null ? 0 : int.parse(ratingNurse.data['5']);
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
      DocumentSnapshot doc = await patientCollection.document(userId).get();
      if (doc.data != null) {
        user = UserData(
          specializationBranch: doc.data['specializationBranch'] ?? '',
          specialization: doc.data['specialization'] ?? '',
          name: doc.data['name'] ?? '',
          docId: doc.documentID ?? '',
          lat: doc.data['lat'] ?? '',
          lng: doc.data['lng'] ?? '',
          nationalId: doc.data['nationalId'] ?? '',
          gender: doc.data['gender'] ?? '',
          birthDate: doc.data['birthDate'] ?? '',
          address: doc.data['address'] ?? '',
          phoneNumber: doc.data['phoneNumber'] ?? '',
          imgUrl: doc.data['imgUrl'] ?? '',
          email: doc.data['email'] ?? '',
          aboutYou: doc.data['aboutYou'] ?? '',
          points: doc.data['points'] ?? '',
        );
      }
    } else {
      DocumentSnapshot doc = await nursesCollection.document(userId).get();
      DocumentSnapshot rating = await nursesCollection.document(userId).collection('rating').document('rating').get();
      if(rating.exists) {
        int one = rating.data['1'] == null ? 0 : int.parse(rating.data['1']);
        int two = rating.data['2'] == null ? 0 : int.parse(rating.data['2']);
        int three = rating.data['3'] == null ? 0 : int.parse(rating.data['3']);
        int four = rating.data['4'] == null ? 0 : int.parse(rating.data['4']);
        int five = rating.data['5'] == null ? 0 : int.parse(rating.data['5']);
        totalRatingForNurse =
            (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                (one + two + three + four + five);
      }
      user = UserData(
        specializationBranch: doc.data['specializationBranch'] ?? '',
        specialization: doc.data['specialization'] ?? '',
        rating: totalRatingForNurse.toString(),
        name: doc.data['name'] ?? '',
        docId: doc.documentID ?? '',
        lat: doc.data['lat'] ?? '',
        lng: doc.data['lng'] ?? '',
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
    }
    return user;
  }

  Future getAllAcceptedRequests({String userId,String userLat='0.0',String userLong='0.0'}) async {
    var requests = databaseReference.collection('requests');
    QuerySnapshot docs =
        await requests.where('nurseId', isEqualTo: userId).getDocuments();
    double distance = 0.0;
    allAcceptedRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      String time='';
      String acceptTime=''; List<String> convertAllVisitsTime=[];
      for (int i = 0; i < docs.documents.length; i++) {
        distance = _calculateDistance(
           userLat != '0.0'? double.parse(userLat):0.0,
            userLong != '0.0'? double.parse(userLong):0.0,
            double.parse(docs.documents[i].data['lat']??'0.0'),
            double.parse(docs.documents[i].data['long']??'0.0'));
        print('distance::$distance');
          if(docs.documents[i].data['time'] !=''){
            time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
          }else{
            time='';
          }
          if(docs.documents[i].data['acceptTime'] !=null&&docs.documents[i].data['acceptTime'] !=''){
            acceptTime=convertTimeToAMOrPM(time: docs.documents[i].data['acceptTime']);
          }else{
            acceptTime='';
          }
          if (docs.documents[i].data['visitTime'] != '[]') {
            var x = docs.documents[i].data['visitTime'].replaceFirst('[', '').toString();
            String visitTime = x.replaceAll(']', '');
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
              specialization: docs.documents[i].data['specialization'] ?? '',
              specializationBranch: docs.documents[i].data['specializationBranch'] ?? '',
            distance:  distance.floor().toString(),
              lat:  docs.documents[i].data['lat'] ?? '',
              long:  docs.documents[i].data['long'] ?? '',
              acceptTime: acceptTime,
              nurseId: docs.documents[i].data['nurseId'] ?? '',
              patientId: docs.documents[i].data['patientId'] ?? '',
              docId: docs.documents[i].documentID,
              visitTime: convertAllVisitsTime.toString() == '[]'
                  ? ''
                  : convertAllVisitsTime.toString(),
              visitDays: docs.documents[i].data['visitDays'] == '[]'
                  ? ''
                  : docs.documents[i].data['visitDays'] ?? '',
              suppliesFromPharmacy:
              docs.documents[i].data['suppliesFromPharmacy'] ?? '',
              startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
              serviceType: docs.documents[i].data['serviceType'] ?? '',
              picture: docs.documents[i].data['picture'] ?? '',
              patientPhone: docs.documents[i].data['patientPhone'] ?? '',
              patientName: docs.documents[i].data['patientName'] ?? '',
              patientLocation: docs.documents[i].data['patientLocation'] ?? '',
              patientGender: docs.documents[i].data['patientGender'] ?? '',
              patientAge: docs.documents[i].data['patientAge'] ?? '',
              servicePrice: docs.documents[i].data['servicePrice'] ?? '',
              time: time,
              date: docs.documents[i].data['date'] ?? '',
              discountPercentage:
              docs.documents[i].data['discountPercentage'] ?? '',
              nurseGender: docs.documents[i].data['nurseGender'] ?? '',
              numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
              endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
              discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
              priceBeforeDiscount:
              docs.documents[i].data['priceBeforeDiscount'] ?? '',
              analysisType: docs.documents[i].data['analysisType'] ?? '',
              notes: docs.documents[i].data['notes'] ?? '',
              priceAfterDiscount:
              docs.documents[i].data['priceAfterDiscount'].toString() ?? ''));
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
        if (docs.documents.length != 0) {
          print('B');
          double distance = 0.0;
          allPatientsRequests.clear();
          String time='';
          String acceptTime='';
          List<String> convertAllVisitsTime=[];
          for (int i = 0; i < docs.documents.length; i++) {
            distance = _calculateDistance(
                userLat != '0.0'? double.parse(userLat):0.0,
                userLong != '0.0'? double.parse(userLong):0.0,
                double.parse(docs.documents[i].data['lat']??'0.0'),
                double.parse(docs.documents[i].data['long']??'0.0'));
            print('distance::$distance');
            if(docs.documents[i].data['time'] !=''){
              time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
            }else{
              time='';
            }
            if(docs.documents[i].data['acceptTime'] !=null&& docs.documents[i].data['acceptTime'] !=''){
              acceptTime=convertTimeToAMOrPM(time: docs.documents[i].data['acceptTime']);
            }else{
              acceptTime='';
            }

            if (docs.documents[i].data['visitTime'] != '[]') {
              var x = docs.documents[i].data['visitTime'].replaceFirst('[', '').toString();
              String visitTime = x.replaceAll(']', '');
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
                specialization: docs.documents[i].data['specialization'] ?? '',
                specializationBranch: docs.documents[i].data['specializationBranch'] ?? '',
                lat:  docs.documents[i].data['lat'] ?? '',
                distance:  distance.floor().toString(),
                long:  docs.documents[i].data['long'] ?? '',
                isFinished: docs.documents[i].data['isFinished'] ?? false,
                acceptTime: acceptTime,
                nurseId: docs.documents[i].data['nurseId'] ?? '',
                patientId: docs.documents[i].data['patientId'] ?? '',
                docId: docs.documents[i].documentID,
                visitTime: convertAllVisitsTime.toString() == '[]'
                    ? ''
                    : convertAllVisitsTime.toString(),
                visitDays: docs.documents[i].data['visitDays'] == '[]'
                    ? ''
                    : docs.documents[i].data['visitDays'] ?? '',
                suppliesFromPharmacy:
                    docs.documents[i].data['suppliesFromPharmacy'] ?? '',
                startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
                serviceType: docs.documents[i].data['serviceType'] ?? '',
                picture: docs.documents[i].data['picture'] ?? '',
                patientPhone: docs.documents[i].data['patientPhone'] ?? '',
                patientName: docs.documents[i].data['patientName'] ?? '',
                patientLocation:
                    docs.documents[i].data['patientLocation'] ?? '',
                patientGender: docs.documents[i].data['patientGender'] ?? '',
                patientAge: docs.documents[i].data['patientAge'] ?? '',
                servicePrice: docs.documents[i].data['servicePrice'] ?? '',
                time: time,
                date: docs.documents[i].data['date'] ?? '',
                discountPercentage:
                    docs.documents[i].data['discountPercentage'] ?? '',
                nurseGender: docs.documents[i].data['nurseGender'] ?? '',
                numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
                endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
                discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
                priceBeforeDiscount:
                    docs.documents[i].data['priceBeforeDiscount'] ?? '',
                analysisType: docs.documents[i].data['analysisType'] ?? '',
                notes: docs.documents[i].data['notes'] ?? '',
                priceAfterDiscount:
                    docs.documents[i].data['priceAfterDiscount'].toString() ??
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
        .document(userId)
        .collection('archived requests');
    QuerySnapshot docs = await requests.getDocuments();
    allArchivedRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      String time='';
      String acceptTime=''; List<String> convertAllVisitsTime=[];
      for (int i = 0; i < docs.documents.length; i++) {
        if(docs.documents[i].data['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
        }else{
          time='';
        }
        if(docs.documents[i].data['acceptTime'] !=null &&docs.documents[i].data['acceptTime'] !=''){
          acceptTime=convertTimeToAMOrPM(time: docs.documents[i].data['acceptTime']);
        }else{
          acceptTime='';
        }

        if (docs.documents[i].data['visitTime'] != '[]') {
          var x = docs.documents[i].data['visitTime'].replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(']', '');
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
            specialization: docs.documents[i].data['specialization'] ?? '',
            specializationBranch: docs.documents[i].data['specializationBranch'] ?? '',
            acceptTime: acceptTime,
            lat:  docs.documents[i].data['lat'] ?? '',
            long:  docs.documents[i].data['long'] ?? '',
            nurseId: docs.documents[i].data['nurseId'] ?? '',
            patientId: docs.documents[i].data['patientId'] ?? '',
            docId: docs.documents[i].documentID,
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),
            visitDays: docs.documents[i].data['visitDays'] == '[]'
                ? ''
                : docs.documents[i].data['visitDays'] ?? '',
            suppliesFromPharmacy:
                docs.documents[i].data['suppliesFromPharmacy'] ?? '',
            startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
            serviceType: docs.documents[i].data['serviceType'] ?? '',
            picture: docs.documents[i].data['picture'] ?? '',
            patientPhone: docs.documents[i].data['patientPhone'] ?? '',
            patientName: docs.documents[i].data['patientName'] ?? '',
            patientLocation: docs.documents[i].data['patientLocation'] ?? '',
            patientGender: docs.documents[i].data['patientGender'] ?? '',
            patientAge: docs.documents[i].data['patientAge'] ?? '',
            servicePrice: docs.documents[i].data['servicePrice'] ?? '',
            time: time,
            date: docs.documents[i].data['date'] ?? '',
            discountPercentage:
                docs.documents[i].data['discountPercentage'] ?? '',
            nurseGender: docs.documents[i].data['nurseGender'] ?? '',
            numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
            endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
            discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
            priceBeforeDiscount:
                docs.documents[i].data['priceBeforeDiscount'] ?? '',
            analysisType: docs.documents[i].data['analysisType'] ?? '',
            notes: docs.documents[i].data['notes'] ?? '',
            priceAfterDiscount:
                docs.documents[i].data['priceAfterDiscount'].toString() ?? ''));
      }
      print('dfbfdsndd');
      print(allArchivedRequests.length);
      notifyListeners();
    }
  }

  Future getNurseSupplies({String userId}) async {
    var supplies = databaseReference.collection("nurses").document(userId);
    var docs = await supplies.collection('supplying').getDocuments();
    if (docs.documents.length != 0) {
      allNurseSupplies.clear();
      String time='';
      for (int i = 0; i < docs.documents.length; i++) {

        if(docs.documents[i].data['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
        }else{
          time='';
        }
        allNurseSupplies.add(Supplying(
            points: docs.documents[i].data['points'] ?? '',
            date: docs.documents[i].data['date'] ?? '',
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
        StorageUploadTask uploadTask = storageReference.putFile(picture);
        await uploadTask.onComplete;
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
        .document(patientId)
        .collection('requests')
        .document(x.documentID)
        .setData({'docId': x.documentID});
    if (coupon.docId != '') {
      int x = int.parse(coupon.numberOfUses);
      if (x != 0) {
        x = x - 1;
      }
      _coupons.document(coupon.docId).updateData({
        'numberOfUses': x.toString(),
      });
      await users
          .document(patientId)
          .collection('coupons')
          .document(coupon.docId)
          .setData({'couponName': coupon.couponName});
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
          StorageUploadTask uploadTask = storageReference.putFile(picture);
          await uploadTask.onComplete;
          await storageReference.getDownloadURL().then((fileURL) async {
            imgUrl = fileURL;
          });
        } catch (e) {
          print(e);
        }
      }
      DateTime dateTime = DateTime.now();
      await databaseReference.collection('requests').document(docId).setData({
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
      }, merge: true);


      if (coupon.docId != '') {
        int x = int.parse(coupon.numberOfUses);
        if (x != 0) {
          x = x - 1;
        }
        _coupons.document(coupon.docId).updateData({
          'numberOfUses': x.toString(),
        });
        await users
            .document(patientId)
            .collection('coupons')
            .document(coupon.docId)
            .setData({'couponName': coupon.couponName});
      }
      return true;
  }

  Future<bool> endRequest({Requests request, UserData userData}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    CollectionReference allRequests = databaseReference.collection('requests');
    CollectionReference archived =
        databaseReference.collection('archived requests');
    CollectionReference archivedForPatients =
        databaseReference.collection('archivedForPatients');
    DocumentSnapshot getPoints=await nursesCollection
        .document(userData.docId).get();
    int points = int.parse(getPoints['points']);
    print('request.priceAfterDiscount');
    print(request.priceAfterDiscount);
    double priceAfterDiscount=double.parse(request.priceAfterDiscount);
    points = points + priceAfterDiscount.floor();
    await nursesCollection
        .document(userData.docId)
        .updateData({'points': points.toString()});
    DateTime dateTime = DateTime.now();
    await nursesCollection
        .document(userData.docId)
        .collection('archived requests')
        .document(request.docId)
        .setData({
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
      String visitTime = x.replaceAll(']', '');
      List<String> times=visitTime.split(',');
      if(times.length !=0){
        for(int i=0; i<times.length; i++){
          convertAllVisitsTime.add(convertTimeTo24Hour(time: times[i]));
        }
      }
    }else{
      convertAllVisitsTime=[];
    }
    await allRequests.document(request.docId).delete();
    if (request.patientId != '') {
      await patientCollection
          .document(request.patientId)
          .collection('archived requests')
          .document(request.docId)
          .setData({
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
      archivedForPatients.document(request.docId)
          .setData({
        'patientId':request.patientId
      });
    } else {
      await archived.document(request.docId).setData({
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
    await allRequests.document(requestId).setData({'isFinished': true}, merge: true);
    return true;
  }

  Future<bool> sendRequestToCancel({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    await allRequests.document(requestId).updateData({'isFinished': false});
    return true;
  }

  Future<bool> cancelRequest({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    allRequests.document(requestId).updateData({'nurseId': '','acceptTime':null,});
    allAcceptedRequests.removeWhere((x)=>x.docId==requestId);
    notifyListeners();
    return true;
  }

  Future<String> verifyCoupon({String userId,String couponName}) async {
    CollectionReference services = databaseReference.collection("coupons");
    CollectionReference users = databaseReference.collection("users");
    QuerySnapshot isUsedBefore=await users
        .document(userId)
        .collection('coupons').where('couponName', isEqualTo: couponName).getDocuments();
    if(isUsedBefore.documents.length != 0){
      return 'isUserBefore';
    }else{

      QuerySnapshot docs = await services
          .where('couponName', isEqualTo: couponName.trim())
          .getDocuments();
      if (docs.documents.length == 0) {
        return 'false';
      } else {
        List<String> date =
        docs.documents[0].data['expiryDate'].toString().split('-');
        print(date);
        DateTime time =
        DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
        if (price.isAddingDiscount == false &&
            price.servicePrice != 0.0 &&
            docs.documents[0].data['numberOfUses'].toString() != '0' &&
            time.isAfter(DateTime.now())) {
          coupon = Coupon(
            docId: docs.documents[0].documentID,
            couponName: docs.documents[0].data['couponName'],
            discountPercentage: docs.documents[0].data['discountPercentage'],
            expiryDate: docs.documents[0].data['expiryDate'],
            numberOfUses: docs.documents[0].data['numberOfUses'].toString(),
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
            docs.documents[0].data['numberOfUses'] == '0') {
          return 'Coupon not Avilable';
        } else {
          return 'already discount';
        }
      }
    }
  }



  Future<bool> deleteRequest({String patientId,Requests request}) async {
    var requests = databaseReference.collection("requests");
    await requests.document(request.docId).delete();

    if (request.discountCoupon != '') {
      CollectionReference users = databaseReference.collection("users");
      CollectionReference _coupons = databaseReference.collection("coupons");
      QuerySnapshot docs = await _coupons
          .where('couponName', isEqualTo: request.discountCoupon)
          .getDocuments();
      if (docs.documents.length != 0) {
        int x = int.parse(docs.documents[0].data['numberOfUses']);
        x = x + 1;
        await _coupons.document(docs.documents[0].documentID).updateData({
          'numberOfUses': x.toString(),
        });
          await users
              .document(patientId)
              .collection('coupons')
              .document(docs.documents[0].documentID)
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
    requests.document(request.docId).updateData({
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
          realTime = translator.currentLanguage == 'en'
              ? '1:${split[1]} PM'
              : '1:${split[1]} م ';
          break;
        case 14:
          realTime = translator.currentLanguage == 'en'
              ? '2:${split[1]} PM'
              : '2:${split[1]} م ';
          break;
        case 15:
          realTime = translator.currentLanguage == 'en'
              ? '3:${split[1]} PM'
              : '3:${split[1]} م ';
          break;
        case 16:
          realTime = translator.currentLanguage == 'en'
              ? '4:${split[1]} PM'
              : '4:${split[1]} م ';
          break;
        case 17:
          realTime = translator.currentLanguage == 'en'
              ? '5:${split[1]} PM'
              : '5:${split[1]} م ';
          break;
        case 18:
          realTime = translator.currentLanguage == 'en'
              ? '6:${split[1]} PM'
              : '6:${split[1]} م ';
          break;
        case 19:
          realTime = translator.currentLanguage == 'en'
              ? '7:${split[1]} PM'
              : '7:${split[1]} م ';
          break;
        case 20:
          realTime = translator.currentLanguage == 'en'
              ? '8:${split[1]} PM'
              : '8:${split[1]} م ';
          break;
        case 21:
          realTime = translator.currentLanguage == 'en'
              ? '9:${split[1]} PM'
              : '9:${split[1]} م ';
          break;
        case 22:
          realTime = translator.currentLanguage == 'en'
              ? '10:${split[1]} PM'
              : '10:${split[1]} م ';
          break;
        case 23:
          realTime = translator.currentLanguage == 'en'
              ? '11:${split[1]} PM'
              : '11:${split[1]} م ';
          break;
        case 00:
        case 0:
          realTime = translator.currentLanguage == 'en'
              ? '12:${split[1]} PM'
              : '12:${split[1]} م ';
          break;
        case 01:
          realTime = translator.currentLanguage == 'en'
              ? '1:${split[1]} AM'
              : '1:${split[1]} ص ';
          break;
        case 02:
          realTime = translator.currentLanguage == 'en'
              ? '2:${split[1]} AM'
              : '2:${split[1]} ص ';
          break;
        case 03:
          realTime = translator.currentLanguage == 'en'
              ? '3:${split[1]} AM'
              : '3:${split[1]} ص ';
          break;
        case 04:
          realTime = translator.currentLanguage == 'en'
              ? '4:${split[1]} AM'
              : '4:${split[1]} ص ';
          break;
        case 05:
          realTime = translator.currentLanguage == 'en'
              ? '5:${split[1]} AM'
              : '5:${split[1]} ص ';
          break;
        case 06:
          realTime = translator.currentLanguage == 'en'
              ? '6:${split[1]} AM'
              : '6:${split[1]} ص ';
          break;
        case 07:
          realTime = translator.currentLanguage == 'en'
              ? '7:${split[1]} AM'
              : '7:${split[1]} ص ';
          break;
        case 08:
          realTime = translator.currentLanguage == 'en'
              ? '8:${split[1]} AM'
              : '8:${split[1]} ص ';
          break;
        case 09:
          realTime = translator.currentLanguage == 'en'
              ? '9:${split[1]} AM'
              : '9:${split[1]} ص ';
          break;
        case 10:
          realTime = translator.currentLanguage == 'en'
              ? '10:${split[1]} AM'
              : '10:${split[1]} ص ';
          break;
        case 11:
          realTime = translator.currentLanguage == 'en'
              ? '11:${split[1]} AM'
              : '11:${split[1]} ص ';
          break;
        case 12:
          realTime = translator.currentLanguage == 'en'
              ? '12:${split[1]} AM':'12:${split[1]} ص ';
          break;
      }
    return realTime;
  }
  String convertTimeTo24Hour({String time}){
    String realTime = '';
    print('time: $time');

    if(translator.currentLanguage == 'en'){
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
    var docs = await completed.getDocuments();
    if (docs.documents.length != 0) {
      allCompleteRequests.clear();
      String time='';
      for (int i = 0; i < docs.documents.length; i++) {
        if(docs.documents[i].data['time'] !=''){
          time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
        }else{
          time='';
        }
        allCompleteRequests.add(CompleteRequest(
          docId: docs.documents[i].documentID,
          date: docs.documents[i].data['date'] ?? '',
          time: time,
          points: docs.documents[i].data['points'] ?? '',
          analysisType: docs.documents[i].data['analysisType'] ?? '',
          serviceType: docs.documents[i].data['serviceType'] ?? '',
        ));
      }
    }
    notifyListeners();
  }
}
