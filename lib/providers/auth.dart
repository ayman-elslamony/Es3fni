import 'dart:convert';
import 'dart:io';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/models/http_exception.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/screens/add_user_data/add_user_data.dart';
import 'package:helpme/screens/main_screen.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/verify_code.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;
  String _token;
 static String _userId = '';
  double lat= 30.033333;
  double lng=31.233334;
  String address='Cairo';
  String get userId => _userId;
  double totalRatingForNurse = 0.0;

  String signInType = '';

  static String _userType = 'patient';

  static UserData _userData;
  PhoneNumber phoneNumber;

  String get getUserType {
    return _userType;
  }
  String _temporaryToken = '';

  UserData get userData => _userData;

  bool get isAuth {
   if(_token != null ){
     return true;
   }else{
     return false;
   }
  }


  Future<String> get getUserId async {
    var user =  firebaseAuth.currentUser;
    if (user.uid != null) {
      return user.uid;
    } else {
      return null;
    }
  }
  getData({document,String key,String ifNull=''}){
    return document.data().toString().contains(key)?document[key]:ifNull;
  }
  Future<bool> tryToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('signInUsingFBorG')) {
      final dataToSignIn = await json
          .decode(prefs.getString('signInUsingFBorG')) as Map<String, Object>;
      if (dataToSignIn['isSignInUsingFaceBook'] == 'true') {
        await signInUsingFBorG(type: 'FB').then((x) {
          if (x=='true') {
            signInType = 'signInUsingFBorG';
          }
        });
      }
      if (dataToSignIn['isSignInUsingGoogle'] == 'true') {
        String x = await signInUsingFBorG(type: 'G');
          if (x=='true') {
            signInType = 'signInUsingFBorG';
          }
      }
    }
    if (prefs.containsKey('signInUsingEmail')) {
      final dataToSignIn = await json
          .decode(prefs.getString('signInUsingEmail')) as Map<String, Object>;
      await signInUsingEmailForNurse(
              isTryToLogin: true,
              email: dataToSignIn['email'],
              password: dataToSignIn['password'])
          .then((_) {
        signInType = 'signInUsingEmail';
      });
    }
    if (prefs.containsKey('signInUsingPhone')) {
      final dataToSignIn = await json
          .decode(prefs.getString('signInUsingPhone')) as Map<String, Object>;
      print(dataToSignIn['phoneToken']);
      FirebaseAuth auth = FirebaseAuth.instance;

// Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
//      ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber('+44 7123 123 456');
//      var x = await firebaseAuth.signInWithCredential(
//          AuthCredential(providerId: , signInMethod: ));
//      _userId = x.user.uid;
//      await x.user.getIdToken().then((x) {
//        _token = x;
//      });
      signInType = 'signInUsingPhone';
    }

    if (signInType == 'signInUsingFBorG') {
      return true;
    } else if (signInType == 'signInUsingPhone') {

      return true;
    } else {
      return false;
    }
  }

  Future<bool> editProfile(
      {String type,
      String address,
        String lat,String lng,
      String phone,
      File picture,
      String aboutYou}) async {
    print('iam here');
    print(lat);
    print(lng);
    var nurseData = databaseReference.collection("nurses");
    var patientData = databaseReference.collection("users");

    try {
      if (type == 'image') {
        String imgUrl = '';
        if (picture != null) {
          try {
            var storageReference = FirebaseStorage.instance
                .ref()
                .child('${userData.name}/${path.basename(picture.path)}');
            var uploadTask = storageReference.putFile(picture);
            await uploadTask;
            await storageReference.getDownloadURL().then((fileURL) async {
              imgUrl = fileURL;
            });
          } catch (e) {
            print(e);
          }
        }
        if (_userType == 'nurse') {
          nurseData.doc(_userId).set({
            'imgUrl': imgUrl,
          }, SetOptions(merge: true));
        } else {
          patientData.doc(_userId).set({
            'imgUrl': imgUrl,
          }, SetOptions(merge: true));
        }
      }
      if (type == 'Another Info') {
        nurseData.doc(_userId).set({'aboutYou': aboutYou}, SetOptions(merge: true));
      }
      if (type == 'Address') {
        if (_userType == 'nurse') {
          nurseData.doc(_userId).set({
            'address': address,
            'lat':lat??'',
            'lng':lng??''
          }, SetOptions(merge: true));
        } else {
          patientData.doc(_userId).set({
            'address': address,
            'lat':lat??'',
            'lng':lng??''
          }, SetOptions(merge: true));
        }
      }
      if (type == 'Phone Number') {
        nurseData.doc(_userId).set({
          'phoneNumber': phone,
        }, SetOptions(merge: true));
      }
      DocumentSnapshot<Map<String, dynamic>> doc;
      if (_userType == 'nurse') {
        doc = await nurseData.doc(_userId).get();
        _userData = UserData(
          specialization:getData(document: doc,key: 'specialization')??'',
          specializationBranch: getData(document: doc,key: 'specializationBranch'),
          name:  getData(document: doc,key: 'name')??'',
          docId: doc.id,
          nationalId: getData(document: doc,key: 'nationalId')??'',
          gender: getData(document: doc,key: 'gender')??'',
          birthDate: getData(document: doc,key: 'birthDate')??'',
          address: getData(document: doc,key: 'address')??'',
          phoneNumber: getData(document: doc,key: 'phoneNumber')??'',
          imgUrl: getData(document: doc,key: 'imgUrl')??'',
          email: getData(document: doc,key: 'email')??'',
          lat:getData(document: doc,key: 'lat')??'' ,
          lng: getData(document: doc,key: 'lng')??'',
          aboutYou: getData(document: doc,key: 'aboutYou')??'',
          points:getData(document: doc,key: 'points')??'',
        );
      } else {
        doc = await patientData.doc(_userId).get();
        _userData = UserData(
          specialization:getData(document: doc,key: 'specialization')??'',
          specializationBranch: getData(document: doc,key: 'specializationBranch')??'',
          isVerify:  doc.data().toString().contains('isVerify')? doc['isVerify'] =='false'?'false':'true':'',
          name:  getData(document: doc,key: 'name')??'',
          docId: doc.id,
          nationalId: getData(document: doc,key: 'nationalId')??'',
          gender: getData(document: doc,key: 'gender')??'',
          birthDate: getData(document: doc,key: 'birthDate')??'',
          address: getData(document: doc,key: 'address')??'',
          phoneNumber: getData(document: doc,key: 'phoneNumber')??'',
          imgUrl: getData(document: doc,key: 'imgUrl')??'',
          email: getData(document: doc,key: 'email')??'',
          lat:getData(document: doc,key: 'lat')??'0.0' ,
          lng: getData(document: doc,key: 'lng')??'0.0',
          aboutYou: getData(document: doc,key: 'aboutYou')??'',
          points:getData(document: doc,key: 'points')??'',
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

Future<bool>  checkIsPatientVerify()async{
    CollectionReference patientData = databaseReference.collection("users");
    DocumentSnapshot doc =await patientData.doc(_userId).get();
    bool isVerify=false;
    if(doc.data().toString().contains('isVerify')){
      if(doc['isVerify'] == 'false'){
        isVerify = false;
      }else if(doc['isVerify'] == ''){
        isVerify = false;
      }else{
        isVerify =true;
      }
    }
    return isVerify;
  }


  Future<String> signInUsingFBorG({String type, BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('savePhoneNumber')){
      prefs.remove('savePhoneNumber');
    }
    String returns='true';
    _userType = 'patient';
     if(type == "FB"){
      // final LoginResult loginResult = await FacebookAuth.instance.login();

       // Create a credential from the access token
       //final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken.token);
//          if (loginResult.status == LoginStatus.success) {
//            final user =
//            await firebaseAuth.signInWithCredential(facebookAuthCredential);
//            _userId = user.user.uid;
//            var patientData = databaseReference.collection("users");
//            DocumentSnapshot doc = await patientData.doc(_userId).get();
//            if(!doc.exists || !doc['nationalId']){
//              _userData = UserData(
//                  specializationBranch: '',
//                  specialization: '',
//                  rating: '0.0',
//                  name: user.user.displayName??'',
//                  points: '0',
//                  docId: user.user.uid,
//                  nationalId: '',
//                  gender: '',
//                  birthDate: '',
//                  address: '',
//                  phoneNumber: phoneNumber??'',
//                  imgUrl: user.user.photoURL??'',
//                  email:user.user.email??'',
//                  aboutYou:'');
//              String x =await  user.user.getIdToken();
//              _temporaryToken= x;
//              returns = 'GoToRegister';
          //  }else{
//              _userData = UserData(
//                  specializationBranch: '',
//                  specialization: '',
//                  isVerify: doc['isVerify']!=null ? doc['isVerify'] =='false'?'false':'true':'',
//                  name: doc['name'] ?? 'Patient',
//                  points: doc['points'] ?? '0',
//                  docId: doc.id,
//                  nationalId: doc['nationalId'] ?? '',
//                  gender: doc['gender'] ?? '',
//                  birthDate: doc['birthDate'] ??'',
//                  address: doc['address'] ?? '',
//                  lat: doc['lat'] ?? '',
//                  lng: doc['lng'] ??'',
//                  phoneNumber: doc['phoneNumber'] ?? '',
//                  imgUrl: doc['imgUrl'] ?? '',
//                  email:doc['email'] ?? '',
//                  aboutYou: doc['aboutYou']??  '');
//              String x =await  user.user.getIdToken();
//              _token = x;
//
//              final _signInUsingFBorG = json.encode({
//                'isSignInUsingFaceBook': 'true',
//                'isSignInUsingGoogle': 'false',
//              });
//              prefs.setString('signInUsingFBorG', _signInUsingFBorG);
//              returns = 'true';
//            }
//          }
          print('D');
          return 'false';
      }
     else{
       final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
       // Obtain the auth details from the request
       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
       // Create a new credential
       final credential = GoogleAuthProvider.credential(
         accessToken: googleAuth?.accessToken,
         idToken: googleAuth?.idToken,
       );
            UserCredential user =
          await firebaseAuth.signInWithCredential(credential);
          _userId = user.user.uid;
          var patientData = databaseReference.collection("users");
          DocumentSnapshot doc = await patientData.doc(_userId).get();
          print('A');
          if(doc.exists == false){
            _userData = UserData(
                specializationBranch: '',
                specialization: '',
                name: user.user.displayName??'',
                points: '0',
                docId: user.user.uid,
                nationalId: '',
                gender: '',
                birthDate: '',
                address: '',
                phoneNumber: phoneNumber??'',
                imgUrl: user.user.photoURL??'',
                email:user.user.email??'',
                aboutYou:'');
            await user.user.getIdToken().then((x) {
              _temporaryToken= x;
            });
            returns = 'GoToRegister';
          }else{
            print('B');
            _userData = UserData(
                specializationBranch: '',
                specialization: '',
                isVerify: doc.data().toString().contains('isVerify')? doc['isVerify'] =='false'?'false':'true':'',
                name: doc.data().toString().contains('name')? doc.get('name'):'Patient',
                points: doc.data().toString().contains('points')? doc['points']:'0',
                docId: doc.id,
                nationalId: getData(document: doc,key: 'nationalId'),
                gender: getData(document: doc,key: 'gender'),
                birthDate: getData(document: doc,key: 'birthDate'),
                address: getData(document: doc,key: 'address'),
                lat: getData(document: doc,key: 'lat'),
                lng: getData(document: doc,key: 'lng'),
                phoneNumber: getData(document: doc,key: 'phoneNumber'),
                imgUrl: getData(document: doc,key: 'imgUrl'),
                email: user.user.email,
                aboutYou: getData(document: doc,key: 'aboutYou'));
            String token=await user.user.getIdToken();
            print('token.token');
            print(token);
            _token=token;
              final _signInUsingFBorG = json.encode({
                'isSignInUsingFaceBook': 'false',
                'isSignInUsingGoogle': 'true',
              });
              prefs.setString('signInUsingFBorG', _signInUsingFBorG);
            returns = 'true';
          }
          return returns;
      }
  }




  Future<void> signInUsingPhone(
      {PhoneNumber phone, BuildContext context, DeviceInfo infoWidget}) async {
    _userType = 'patient';
    phoneNumber = phone;
    var patientData = databaseReference.collection("users");
    final prefs = await SharedPreferences.getInstance();
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          print('dfbfbff');
          UserCredential result =
              await firebaseAuth.signInWithCredential(credential);
          User user = result.user;
          if (user != null) {
            _userId = user.uid;
            if (_token == null) {

                if (user != null) {
                  await user.getIdToken().then((token) {
                    print(token);
                    _token = token;
                  });
                }
              print(_userId);
              print(_token);
              final _signInUsingPhone = json.encode({
                'phoneToken': _token,
              });
              final _savePhoneNumber = json.encode({
                'PhoneNumber': phone.phoneNumber,
                'dialCode':phoneNumber.dialCode,
                'isoCode':phoneNumber.isoCode,
              });
              prefs.setString('savePhoneNumber', _savePhoneNumber);
              prefs.setString('signInUsingPhone', _signInUsingPhone);
              print('rytryhrrhr');
              DocumentSnapshot doc = await patientData.doc(_userId).get();
              if (!doc.exists) {
                _userData = UserData(
                    specializationBranch:'',
                    specialization: '',
                    name: '',
                    points: '0',
                    docId: '',
                    nationalId: '',
                    gender: '',
                    birthDate: '',
                    address: '',
                    phoneNumber: phoneNumber.phoneNumber??'',
                    imgUrl: '',
                    email:'',
                    aboutYou:'');
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AddUserData()));
              } else {
                _userData = UserData(
                    specializationBranch: '',
                    specialization: '',
                    isVerify: doc.data().toString().contains('isVerify')? doc['isVerify'] =='false'?'false':'true':'',
                    name: doc.data().toString().contains('name')? doc['name']:'Patient',
                    points: doc.data().toString().contains('points')? doc['points']:'0',
                    docId: doc.id,
                    nationalId: getData(document: doc,key: 'nationalId'),
                    gender: getData(document: doc,key: 'gender'),
                    birthDate: getData(document: doc,key: 'birthDate'),
                    address: getData(document: doc,key: 'address'),
                    lat: getData(document: doc,key: 'lat'),
                    lng: getData(document: doc,key: 'lng'),
                    phoneNumber: getData(document: doc,key: 'phoneNumber'),
                    imgUrl: getData(document: doc,key: 'imgUrl'),
                    email: getData(document: doc,key: 'email'),
                    aboutYou: getData(document: doc,key: 'aboutYou'));
                notifyListeners();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
            }
          } else {
            print("Error");
          }
        },
        verificationFailed: (exception) {
          print('vdbcdbd');
          print(exception.message);
          Toast.show(
              translator.activeLanguageCode == "en"
                  ? "you are send more requests please try again later"
                  : 'لقد قمت بطلب الكود اكثر من مره من فضلك حاول فى وق لاحق',
              context,
              duration: Toast.LENGTH_LONG,
              gravity: Toast.BOTTOM);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          getCode(String code) async {
            print('etey$code');
            try {
              AuthCredential credential = PhoneAuthProvider.credential(
                  verificationId: verificationId, smsCode: code);
              UserCredential result =
                  await firebaseAuth.signInWithCredential(credential);
              User user = result.user;
              print('etetee');
              if (user != null) {
                _userId = user.uid;
                if (_token == null) {
                    if (user != null) {
                      await user.getIdToken().then((token) {
                        print(token);
                        _token = token;
                      });
                    }

                  print(_userId);
                  print(_token);
                  final _signInUsingPhone = json.encode({
                    'phoneToken': _token,
                  });
                  final _savePhoneNumber = json.encode({
                    'PhoneNumber': phone.phoneNumber,
                    'dialCode':phoneNumber.dialCode,
                    'isoCode':phoneNumber.isoCode,
                  });
                  prefs.setString('savePhoneNumber', _savePhoneNumber);
                  print('wtrwetetetetyyyyyyyyyyyyyyyyyyyy');
                  prefs.setString('signInUsingPhone', _signInUsingPhone);
                  DocumentSnapshot doc =
                      await patientData.doc(_userId).get();
                  if (!doc.exists) {
                    _userData = UserData(
                      specializationBranch: '',
                        specialization: '',
                        name: '',
                        points: '0',
                        docId: '',
                        nationalId: '',
                        gender: '',
                        birthDate: '',
                        address: '',
                        phoneNumber: phoneNumber.phoneNumber??'',
                        imgUrl: '',
                        email:'',
                        aboutYou:'');
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => AddUserData()));
                  } else {
                    _userData = UserData(
                        specializationBranch: '',
                        specialization: '',
                        isVerify: doc.data().toString().contains('isVerify')? doc['isVerify'] =='false'?'false':'true':'',
                        name: doc.data().toString().contains('name')? doc['name']:'Patient',
                        points: doc.data().toString().contains('points')? doc['points']:'0',
                        docId: doc.id,
                        nationalId: getData(document: doc,key: 'nationalId'),
                        gender: getData(document: doc,key: 'gender'),
                        birthDate: getData(document: doc,key: 'birthDate'),
                        address: getData(document: doc,key: 'address'),
                        lat: getData(document: doc,key: 'lat'),
                        lng: getData(document: doc,key: 'lng'),
                        phoneNumber: phoneNumber.phoneNumber.toString(),
                        imgUrl: getData(document: doc,key: 'imgUrl'),
                        email: getData(document: doc,key: 'email'),
                        aboutYou: getData(document: doc,key: 'aboutYou'));
                    notifyListeners();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }
                }
              } else {
                print("Error");
              }
            } catch (e) {
              print(e);
              Toast.show(
                  translator.activeLanguageCode == "en"
                      ? "invalid verification code"
                      : 'الكود الذى ادخلته غير صحيح',
                  context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.BOTTOM);
            }
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyCode(
                    phoneNumber: phone,
                    function: getCode,
                  )));
        },
        codeAutoRetrievalTimeout: null);
  }

  Future<void>  getNurseRating()async{
    var users = databaseReference.collection("nurses");
    print('frgry5r');
     users.doc(_userId).collection('rating').doc('rating').snapshots().listen((DocumentSnapshot<Map<String, dynamic>> rating){
       print('dfgsfgsdf');
        if(rating.exists) {
          int one = rating.data().toString().contains('1')? int.parse(rating.data()['1']??'0'): 0 ;
          int two = rating.data().toString().contains('2')? int.parse(rating.data()['2']??'0'): 0 ;
          int three = rating.data().toString().contains('3')? int.parse(rating.data()['3']??'0'): 0 ;
          int four = rating.data().toString().contains('4')? int.parse(rating.data()['4']??'0'): 0 ;
          int five = rating.data().toString().contains('5')? int.parse(rating.data()['5']??'0'): 0 ;
          totalRatingForNurse =
              (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                  (one + two + three + four + five);
        }else{
          totalRatingForNurse =0.0;
        }

        notifyListeners();
      });

    }

  Future<bool> signInUsingEmailForNurse(
      {String email,
      String password,
      BuildContext context,
      bool isTryToLogin = false}) async {
    print(email);
    print(password);
    var auth;
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('savePhoneNumber')){
      prefs.remove('savePhoneNumber');
    }
    _userType = 'nurse';
    var users = databaseReference.collection("nurses");
    bool isRegisterData = true;
    bool isLogout = false;
    try {
      auth = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (auth != null) {
        _userId = auth.user.uid;
        String x = await auth.user.getIdToken();
        DocumentSnapshot doc = await users.doc(_userId).get();
        if (doc.data().toString().contains('address')||
            doc.data().toString().contains('phoneNumber')||
                doc.data().toString().contains('gender')) {
          if (isTryToLogin == false) {
            _userData = UserData(
                specializationBranch: '',
                specialization: '',
                name: doc.data().toString().contains('name')? doc['name']:'Nurse',
                docId: doc.id,
                rating: '0.0',
                password: password,
                nationalId: getData(document: doc,key: 'nationalId'),
                gender: getData(document: doc,key: 'gender'),
                birthDate: getData(document: doc,key: 'birthDate'),
                address: getData(document: doc,key: 'address'),
                lat: getData(document: doc,key: 'lat'),
                lng: getData(document: doc,key: 'lng'),
                phoneNumber:getData(document: doc,key: 'phoneNumber'),
                imgUrl: getData(document: doc,key: 'imgUrl'),
                email: getData(document: doc,key: 'email'),
                aboutYou: getData(document: doc,key: 'aboutYou'));
            isLogout = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddUserData()));
            isRegisterData = false;
          }
        } else {
          _userData = UserData(
              name: doc.data().toString().contains('name')? doc['name']:'Nurse',
              docId: doc.id,
              specializationBranch:getData(document: doc,key: 'specializationBranch'),
              specialization: getData(document: doc,key: 'specialization'),
              points: doc.data().toString().contains('points')? doc['points'].toString() : '0',
              nationalId: getData(document: doc,key: 'nationalId'),
              gender: getData(document: doc,key: 'gender'),
              birthDate: getData(document: doc,key: 'birthDate'),
              address: getData(document: doc,key: 'address'),
              lat: getData(document: doc,key: 'lat'),
              lng: getData(document: doc,key: 'lng'),
              phoneNumber:getData(document: doc,key: 'phoneNumber'),
              imgUrl: getData(document: doc,key: 'imgUrl'),
              email: getData(document: doc,key: 'email'),
              aboutYou: getData(document: doc,key: 'aboutYou'));
              isRegisterData = true;
        }
        if (isTryToLogin) {
          _token = x;
        } else {
          _temporaryToken = x;
        }
        print('isLogout ');
        print(isLogout);
        if (isLogout == false) {
          final prefs = await SharedPreferences.getInstance();
          if (!prefs.containsKey('signInUsingEmail')) {
            final _signInUsingEmail = json.encode({
              'email': email,
              'password': password,
            });
            prefs.setString('signInUsingEmail', _signInUsingEmail);
          }
        }
      }
      if (isTryToLogin == false) {
        notifyListeners();
      }
      return isRegisterData;
    } catch (e) {
      print('eee');
      print(e);
      throw HttpException(e.code);
    }
  }

  setIsActive() async {
    var nurseData = databaseReference.collection("nurses");
    await nurseData.doc(_userId).set({
      "isActive": true,
    },SetOptions(merge: true));
  }
  setUnActive() async {
    var nurseData = databaseReference.collection("nurses");
    await nurseData.doc(_userId).set({
      "isActive": false,
    },SetOptions(merge: true));
  }

  Future<bool>  verifyUniqueId({String id})async{
    var patientCollection = databaseReference.collection("users");
    var docs =await patientCollection.get();
    bool verify = true;
    if(docs.docs.isNotEmpty){
      for(int i=0; i<docs.docs.length; i++){
        if(docs.docs[i].get('nationalId') == id){
          verify = false;
          break ;
        }
      }
    }
    return verify;
  }

  Future<bool> addUserData({
    String name = '',
    var pictureId,
    String location = '',
    String lat,
    String lng,
    String phoneNumber = '',
    String aboutYou = '',
    String birthDate = '',
    String gender = '',
    var picture,
    String nationalId,
  }) async {

print('dfdfd');
    int points = 0;
    if(name!= ''){
      points = points + 5;
    }

print(location);
    print('rtr');
    var nurseData = databaseReference.collection("nurses");
    var patientData = databaseReference.collection("users");
    DateTime dateTime = DateTime.now();
    String imgUrl = '';
    String idImgUrl = '';
    print('picture');
    print(picture);
    final prefs = await SharedPreferences.getInstance();
    if (picture.toString().contains('https:') == false) {
      try {
        var storageReference =  FirebaseStorage.instance
            .ref()
            .child('$name/${path.basename(picture.path)}');
         var uploadTask = storageReference.putFile(picture);
        await uploadTask;
        await storageReference.getDownloadURL().then((fileURL) async {
          imgUrl = fileURL;
        });
      } catch (e) {
        print(e);
      }
    }
    if (_userType == 'nurse') {
      nurseData.doc(_userId).set({
        'name': name,
        'address': location,
        'lat':lat??'',
        'lng':lng??'',
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'gender': gender,
        'imgUrl': imgUrl,
        'aboutYou': aboutYou,
        'points': '0'//initial points for user
      }, SetOptions(merge: true));
      _userType = 'nurse';
      _token = _temporaryToken;

      if (!prefs.containsKey('signInUsingEmail')) {
        final _signInUsingEmail = json.encode({
          'email': _userData.email,
          'password': _userData.password,
        });
        prefs.setString('signInUsingEmail', _signInUsingEmail);
      }
    } else {
        try {
          var storageReference =  FirebaseStorage.instance
              .ref()
              .child('$name/${path.basename(pictureId.path)}');
          var uploadTask = storageReference.putFile(pictureId);
          await uploadTask;
          await storageReference.getDownloadURL().then((fileURL) async {
            idImgUrl = fileURL;
          });
        } catch (e) {
          print(e);
        }
      patientData.doc(_userId).set({
        'name': name,
        'address': location,
        'lat':lat??'',
        'lng':lng??'',
        'isVerify': 'false',
        'pictureId':idImgUrl,
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'nationalId': nationalId,
        'gender': gender,
        'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        'time': '${dateTime.hour}:${dateTime.minute}',
        'imgUrl': picture.toString().contains('https:')?picture:imgUrl,
        'points': '0'
      }, SetOptions(merge: true));
      _userType = 'patient';
      _token = _temporaryToken;
      if(this.phoneNumber ==null){
        final _signInUsingFBorG = json.encode({
          'isSignInUsingFaceBook': 'false',
          'isSignInUsingGoogle': 'true',
        });
        prefs.setString('signInUsingFBorG', _signInUsingFBorG);
      }
    }
    DocumentSnapshot doc;
    if (_userType == 'nurse') {
      doc = await nurseData.doc(_userId).get();
    } else {
      doc = await patientData.doc(_userId).get();
    }
    _userData = UserData(
        name: doc.data().toString().contains('name')? doc['name']:'Nurse',
        docId: doc.id,
        rating: '0.0',
        isVerify: doc.data().toString().contains('isVerify')?doc['isVerify'] =='false'?'false':'true':'',
        specializationBranch:getData(document: doc,key: 'specializationBranch'),
        specialization: getData(document: doc,key: 'specialization'),
        points: doc.data().toString().contains('points')? doc['points'].toString() : '0',
        nationalId: getData(document: doc,key: 'nationalId'),
        gender: getData(document: doc,key: 'gender'),
        birthDate: getData(document: doc,key: 'birthDate'),
        address: getData(document: doc,key: 'address'),
        lat: getData(document: doc,key: 'lat'),
        lng: getData(document: doc,key: 'lng'),
        phoneNumber:getData(document: doc,key: 'phoneNumber'),
        imgUrl: getData(document: doc,key: 'imgUrl'),
        email: getData(document: doc,key: 'email'),
        aboutYou: getData(document: doc,key: 'aboutYou'));
    notifyListeners();
    return true;
  }

  Future<bool> logout() async {
    try {
      firebaseAuth.signOut();
      _token = null;
      _userId = null;
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }
}
