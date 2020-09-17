import 'dart:io';
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
  final String authToken;
  final String authId;
  Home(
      this.authToken,
      this.authId
      );

  List<Service> allService = [];
  List<Analysis> allAnalysis = [];
  List<String> allServicesType =
  translator.currentLanguage == "en" ? ['Analysis'] : ['تحاليل'];
  List<String> allAnalysisType = [];
  List<Requests> allPatientsRequests = [];
  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon =
  Coupon(docId: '',couponName: '', discountPercentage: '0.0', numberOfUses: '0');
  double discount = 0.0;
  double priceBeforeDiscount = 0.0;

  Future<String> verifyCoupon({String couponName}) async {
    var services = databaseReference.collection("coupons");
    QuerySnapshot docs = await services
        .where('couponName', isEqualTo: couponName)
        .getDocuments();
    if (docs.documents.length == 0) {
      return 'false';
    } else {
      List<String> date  = docs.documents[0].data['expiryDate'].toString().split('-');
      print(date);
      DateTime time =DateTime(int.parse(date[2]),
          int.parse(date[1]),
          int.parse(date[0])
      );
      if (price.isAddingDiscount == false && price.servicePrice != 0.0 && docs.documents[0].data['numberOfUses']!='0' && time.isAfter(DateTime.now())) {
        coupon = Coupon(
          docId: docs.documents[0].documentID,
          couponName: docs.documents[0].data['couponName'],
          discountPercentage: docs.documents[0].data['discountPercentage'],
          expiryDate: docs.documents[0].data['expiryDate'],
          numberOfUses: docs.documents[0].data['numberOfUses'],
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
      }else if(!time.isAfter(DateTime.now())|| docs.documents[0].data['numberOfUses']=='0'){
        return 'Coupon not Avilable';
      } else {
        return 'already discount';
      }
    }
  }

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
  resetPrice() {
    price = Price(allServiceType: [], servicePrice: 0.0);
  }
  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.getDocuments();
    allService.clear();
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

  Future getAllRequests() async {
    var requests = databaseReference.collection('analysis request');
    QuerySnapshot docs = await requests.getDocuments();
    allPatientsRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      for (int i = 0; i < docs.documents.length; i++) {
        allPatientsRequests.add(Requests(
            patientId: docs.documents[i].data['patientId'] ?? '',
            docId: docs.documents[i].documentID,
            visitTime: docs.documents[i].data['visitTime'] == '[]'
                ? ''
                : docs.documents[i].data['visitTime'] ?? '',
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
            time: docs.documents[i].data['time'] ?? '',
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
      print(allPatientsRequests.length);
      notifyListeners();
    }
  }
  Future<bool> addRequest(
      {String analysisType,
        String patientName,
        String patientPhone,
        String patientLocation,
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
    var docs =
    await users.where('phone', isEqualTo: patientPhone).getDocuments();
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
    DateTime dateTime = DateTime.now().toUtc();
    if (analysisType == '') {
      print('aaa');
      DocumentReference x = await databaseReference.collection('requests').add({
        'patientId':
        docs.documents.length != 0 ? docs.documents[0].documentID : '',
        'patientName': patientName,
        'patientPhone': patientPhone,
        'patientLocation': patientLocation,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'numOfPatients': numOfPatients,
        'discountPercentage': coupon.discountPercentage,
        'serviceType': serviceType,
        'nurseGender': nurseGender,
        'suppliesFromPharmacy': suppliesFromPharmacy,
        'picture': imgUrl,
        'discountCoupon': discountCoupon,
        'startVisitDate': startVisitDate,
        'endVisitDate': endVisitDate,
        'visitDays': visitDays,
        'visitTime': visitTime,
        'notes': notes,
        'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        'time': '${dateTime.hour}:${dateTime.minute}',
        'servicePrice': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'priceBeforeDiscount': discountCoupon == ''
            ? (double.parse(numOfPatients) * price.servicePrice).toString()
            : (double.parse(numOfPatients) * priceBeforeDiscount).toString(),
        'priceAfterDiscount':
        (double.parse(numOfPatients) * price.servicePrice).toString(),
      });
      if (docs.documents.length != 0) {
        await users
            .document(docs.documents[0].documentID)
            .collection('requests')
            .document(x.documentID)
            .setData({'docId': x.documentID});
      }
      print('bb');
    } else {
      DocumentReference x =
      await databaseReference.collection('analysis request').add({
        'patientId':
        docs.documents.length != 0 ? docs.documents[0].documentID : '',
        'patientName': patientName,
        'patientPhone': patientPhone,
        'patientLocation': patientLocation,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'numOfPatients': numOfPatients,
        'serviceType': serviceType,
        'analysisType': analysisType,
        'nurseGender': nurseGender,
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
        'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        'time': '${dateTime.hour}:${dateTime.minute}',
        'visitDays': visitDays,
        'visitTime': visitTime,
        'notes': notes,
        'priceBeforeDiscount': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'priceAfterDiscount': price.servicePrice,
      });
      if (docs.documents.length != 0) {
        await users
            .document(docs.documents[0].documentID)
            .collection('analysis request')
            .document(x.documentID)
            .setData({'docId': x.documentID});
      }
    }
    if(coupon.docId != ''){
      int x = int.parse(coupon.numberOfUses);
      if(x != 0){
        x =x-1;
      }
      _coupons.document(coupon.docId).updateData({
        'numberOfUses': x,
      });
    }
    getAllRequests();
    return true;
  }
}
