import 'dart:io';
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
    requests.where('nurseId', isEqualTo: '').snapshots().listen((docs) {
      print(docs.documents);
      allPatientsRequests.clear();
      print('A');
      if (docs.documents.length != 0) {
        print('B');
        String time='';
        String acceptTime='';
        List<String> convertAllVisitsTime=[];
        for (int i = 0; i < docs.documents.length; i++) {
          if(docs.documents[i].data['time'] !=''){
            time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
          }else{
            time='';
          }
          if(docs.documents[i].data['acceptTime'] !=''){
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
          allPatientsRequests.add(Requests(
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
                  docs.documents[i].data['priceAfterDiscount'].toString() ??
                      ''));
        }
        print('dfbfdsndd');
        print(allPatientsRequests.length);
      } else {
        allPatientsRequests.clear();
      }
      notifyListeners();
    });
  }

  Future<UserData> getUserData({String type, String userId}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    UserData user;
    if (type == 'Patient' || type == 'مريض') {
      DocumentSnapshot doc = await patientCollection.document(userId).get();
      if (doc.data != null) {
        user = UserData(
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
      user = UserData(
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

  Future getAllAcceptedRequests({String userId}) async {
    var requests = databaseReference.collection('requests');
    QuerySnapshot docs =
        await requests.where('nurseId', isEqualTo: userId).getDocuments();

    allAcceptedRequests.clear();
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
        if(docs.documents[i].data['acceptTime'] !=''){
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
      }
      print('dfbfdsndd');
      print(allAcceptedRequests.length);
    }
    notifyListeners();
  }

  Future getAllPatientRequests({String userId, String userType}) async {
    if (userType == 'patient') {
      var requests = databaseReference.collection('requests');
      requests.where('patientId', isEqualTo: userId).snapshots().listen((docs) {
        print('A');
        if (docs.documents.length != 0) {
          print('B');
          allPatientsRequests.clear();
          String time='';
          String acceptTime=''; List<String> convertAllVisitsTime=[];
          for (int i = 0; i < docs.documents.length; i++) {
            if(docs.documents[i].data['time'] !=''){
              time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
            }else{
              time='';
            }
            if(docs.documents[i].data['acceptTime'] !=null){
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
            allPatientsRequests.add(Requests(
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
        if(docs.documents[i].data['acceptTime'] !=''){
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
        'numberOfUses': x,
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
//    CollectionReference allArchived = databaseReference.collection('archived');
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
      'date': '${dateTime.year}-${dateTime.month}-${dateTime.day}',
      'time': '${dateTime.hour}:${dateTime.minute}',
    });
//    allArchived.document(request.docId).setData({
//      'docId':request.docId,
//      'patientId':request.patientId
//    });


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
    allRequests.document(request.docId).delete();
    if (request.patientId != '') {
      await patientCollection
          .document(request.patientId)
          .collection('archived requests')
          .document(request.docId)
          .setData({
        'acceptTime':acceptTime,
        'nurseId': userData.docId,
        'patientId': request.patientId,
        'patientName': request.patientName,
        'patientPhone': request.patientPhone,
        'patientLocation': request.patientLocation,
        'patientAge': request.patientAge,
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
    } else {
      await archived.document(request.docId).setData({
        'nurseId': userData.docId,
        'patientId': request.patientId,
        'patientName': request.patientName,
        'acceptTime':acceptTime,
        'patientPhone': request.patientPhone,
        'patientLocation': request.patientLocation,
        'patientAge': request.patientAge,
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
    allRequests.document(requestId).setData({'isFinished': true}, merge: true);
    return true;
  }

  Future<bool> sendRequestToCancel({String requestId}) async {
    CollectionReference allRequests = databaseReference.collection('requests');
    allRequests.document(requestId).setData({'isFinished': false}, merge: true);
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
          .where('couponName', isEqualTo: couponName)
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
          'numberOfUses': x,
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
