import 'dart:io';
import 'package:helpme/models/completed_request.dart';
import 'package:helpme/models/supplying.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/providers/auth.dart';
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
    this.authId,
  );

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
  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon = Coupon(
      docId: '', couponName: '', discountPercentage: '0.0', numberOfUses: '0');
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
      List<String> date =
          docs.documents[0].data['expiryDate'].toString().split('-');
      print(date);
      DateTime time =
          DateTime(int.parse(date[2]), int.parse(date[1]), int.parse(date[0]));
      if (price.isAddingDiscount == false &&
          price.servicePrice != 0.0 &&
          docs.documents[0].data['numberOfUses'] != '0' &&
          time.isAfter(DateTime.now())) {
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
      } else if (!time.isAfter(DateTime.now()) ||
          docs.documents[0].data['numberOfUses'] == '0') {
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

  Future getAllRequests() async {
    CollectionReference requests = databaseReference.collection('requests');
//    if (Auth().getUserType == 'nurse') {
//
//    } else {
//      requests = databaseReference.collection('analysis request');
//    }
    var docs = await requests.where('nurseId', isEqualTo: '').getDocuments();
    print(docs.documents);
    allPatientsRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      for (int i = 0; i < docs.documents.length; i++) {
        allPatientsRequests.add(Requests(
            isArchived: docs.documents[i].data['isRequestsArchived'] ?? '',
            nurseId: docs.documents[i].data['nurseId'] ?? '',
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

  Future getAllAcceptedRequests({String userId}) async {
    var requests = databaseReference.collection('requests');
    QuerySnapshot docs  = await requests
        .where('nurseId', isEqualTo: userId)
        .where('isRequestsArchived', isEqualTo: 'false')
        .getDocuments();

    allAcceptedRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      for (int i = 0; i < docs.documents.length; i++) {
        allAcceptedRequests.add(Requests(
            isArchived: docs.documents[i].data['isRequestsArchived'] ?? '',
            nurseId: docs.documents[i].data['nurseId'] ?? '',
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
      print(allAcceptedRequests.length);
      notifyListeners();
    }
  }
  Future getAllPatientRequests({String userId}) async {
    var requests = databaseReference.collection('requests');
    QuerySnapshot
      docs = await requests
          .where('patientId', isEqualTo: userId)
          .getDocuments();

    allPatientsRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      for (int i = 0; i < docs.documents.length; i++) {
        allPatientsRequests.add(Requests(
            isArchived: docs.documents[i].data['isRequestsArchived'] ?? '',
            nurseId: docs.documents[i].data['nurseId'] ?? '',
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
      print(allPatientsRequests.length);
      notifyListeners();
    }
  }
  Future getAllArchivedRequests({String userId}) async {
    var requests = databaseReference.collection('users').document(userId).collection('archived requests');
    QuerySnapshot docs = await requests
        .getDocuments();
    allArchivedRequests.clear();
    print('A');
    if (docs.documents.length != 0) {
      print('B');
      for (int i = 0; i < docs.documents.length; i++) {
        allArchivedRequests.add(Requests(
            isArchived: docs.documents[i].data['isRequestsArchived'] ?? '',
            nurseId: docs.documents[i].data['nurseId'] ?? '',
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
      print(allArchivedRequests.length);
      notifyListeners();
    }
  }

  Future getNurseSupplies({String userId}) async {
    var supplies = databaseReference.collection("nurses").document(userId);
    var docs = await supplies.collection('supplies').getDocuments();
    if (docs.documents.length != 0) {
      allNurseSupplies.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allNurseSupplies.add(Supplying(
            points: docs.documents[i].data['points'] ?? '',
            date: docs.documents[i].data['date'] ?? '',
            time: docs.documents[i].data['time'] ?? ''));
      }
    }
    notifyListeners();
  }

  Future<bool> addRequest(
      {String analysisType,
        String patientId,
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

    DocumentReference x = await databaseReference.collection('requests').add({
      'nurseId': '',
      'isRequestsArchived': 'false',
      'patientId':
      patientId??'',
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
          .collection('requests')
          .document(x.documentID)
          .setData({'docId': x.documentID});
    }
//    if (analysisType == '') {
//      getAllPatientsRequests();
//    } else {
//      getAllAnalysisRequests();
//    }
    if (coupon.docId != '') {
      int x = int.parse(coupon.numberOfUses);
      if (x != 0) {
        x = x - 1;
      }
      _coupons.document(coupon.docId).updateData({
        'numberOfUses': x,
      });
    }
    getAllPatientRequests(userId: patientId);
    return true;
  }

  Future<bool> endRequest({Requests request, UserData userData}) async {
    var nursesCollection = databaseReference.collection("nurses");
    CollectionReference allRequests = databaseReference.collection('requests');
    int points = int.parse(userData.points);
    points = points + 50;
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
      'points': '50',
      'date': '${dateTime.day}-${dateTime.month}-${dateTime.year}',
      'time': '${dateTime.hour}:${dateTime.minute}',
    });
    allRequests
        .document(request.docId)
        .updateData({'isRequestsArchived': 'true'});
    allAcceptedRequests.removeWhere((x)=>x.docId==request.docId);
    userData.points = points.toString();
    notifyListeners();

    return true;
  }
  Future<bool> deleteRequest({String requestId}) async {
    var requests = databaseReference.collection("requests");
    await requests.document(requestId).delete();
    allPatientsRequests.removeWhere((x) => x.docId== requestId);
    notifyListeners();
    return true;
  }
  Future<bool> acceptRequest({Requests request, UserData userData}) async {
    CollectionReference requests = databaseReference.collection('requests');
    requests.document(request.docId).updateData({'nurseId': userData.docId});
    allPatientsRequests.removeWhere((x)=>x.docId==request.docId);
    request.nurseId=userData.docId;
    allAcceptedRequests.add(request);
//    getAllCompletedRequests(userId: userData.docId);
    return true;
  }

  Future getAllCompletedRequests({String userId}) async {
    var completed =
        databaseReference.collection("nurses/$userId/archived requests");
    var docs = await completed.getDocuments();
    if (docs.documents.length != 0) {
      allCompleteRequests.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allCompleteRequests.add(CompleteRequest(
          docId: docs.documents[i].documentID,
          date: docs.documents[i].data['date'] ?? '',
          time: docs.documents[i].data['time'] ?? '',
          points: docs.documents[i].data['points'] ?? '',
          analysisType: docs.documents[i].data['analysisType'] ?? '',
          serviceType: docs.documents[i].data['serviceType'] ?? '',
        ));
      }
    }
    notifyListeners();
  }
}
