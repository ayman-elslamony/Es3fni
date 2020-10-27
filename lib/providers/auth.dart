import 'dart:convert';
import 'dart:io';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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

import 'home.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final Firestore databaseReference = Firestore.instance;
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
    var user = await firebaseAuth.currentUser();
    if (user.uid != null) {
      return user.uid;
    } else {
      return null;
    }
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
      AuthResult x = await firebaseAuth.signInWithCustomToken(
          token: dataToSignIn['phoneToken'].toString());
      _userId = x.user.uid;
      await x.user.getIdToken().then((x) {
        _token = x.token;
      });
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
            StorageUploadTask uploadTask = storageReference.putFile(picture);
            await uploadTask.onComplete;
            await storageReference.getDownloadURL().then((fileURL) async {
              imgUrl = fileURL;
            });
          } catch (e) {
            print(e);
          }
        }
        if (_userType == 'nurse') {
          nurseData.document(_userId).setData({
            'imgUrl': imgUrl,
          }, merge: true);
        } else {
          patientData.document(_userId).setData({
            'imgUrl': imgUrl,
          }, merge: true);
        }
      }
      if (type == 'Another Info') {
        nurseData.document(_userId).setData({'aboutYou': aboutYou}, merge: true);
      }
      if (type == 'Address') {
        if (_userType == 'nurse') {
          nurseData.document(_userId).setData({
            'address': address,
            'lat':lat??'',
            'lng':lng??''
          }, merge: true);
        } else {
          patientData.document(_userId).setData({
            'address': address,
            'lat':lat??'',
            'lng':lng??''
          }, merge: true);
        }
      }
      if (type == 'Phone Number') {
        nurseData.document(_userId).setData({
          'phoneNumber': phone,
        }, merge: true);
      }
      DocumentSnapshot doc;
      if (_userType == 'nurse') {
        doc = await nurseData.document(_userId).get();
      } else {
        doc = await patientData.document(_userId).get();
      }
      _userData = UserData(
        rating: doc.data['rating'] ??'0.0',
        specialization:doc.data['specialization'] ?? '',specializationBranch: doc.data['specializationBranch'] ?? '',
        isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
        name: doc.data['name'],
        docId: doc.documentID,
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        lat: doc.data['lat'] ?? '',
        lng: doc.data['lng'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
Future<bool>  checkIsPatientVerify()async{
    CollectionReference patientData = databaseReference.collection("users");
    DocumentSnapshot doc =await patientData.document(_userId).get();
    bool isVerify=false;
    if(doc.data['isVerify']!=null){
      if(doc.data['isVerify'] == 'false'){
        isVerify = false;
      }else if(doc.data['isVerify'] == ''){
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
          FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
          final accessToken = facebookLoginResult.accessToken.token;
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
            final facebookAuthCred =
            FacebookAuthProvider.getCredential(accessToken: accessToken);
            final user =
            await firebaseAuth.signInWithCredential(facebookAuthCred);
            _userId = user.user.uid;
            var patientData = databaseReference.collection("users");
            DocumentSnapshot doc = await patientData.document(_userId).get();
            if(!doc.exists || !doc.data.keys.contains('nationalId')){
              _userData = UserData(
                  specializationBranch: '',
                  specialization: '',
                  rating: '0.0',
                  name: user.user.displayName??'',
                  points: '0',
                  docId: user.user.uid,
                  nationalId: '',
                  gender: '',
                  birthDate: '',
                  address: '',
                  phoneNumber: phoneNumber??'',
                  imgUrl: user.user.photoUrl??'',
                  email:user.user.email??'',
                  aboutYou:'');
              IdTokenResult x =await  user.user.getIdToken(refresh: true);
              _temporaryToken= x.token;
              returns = 'GoToRegister';
            }else{
              _userData = UserData(
                  specializationBranch: '',
                  specialization: '',
                  isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
                  name: doc.data['name'] ?? 'Patient',
                  points: doc.data['points'] ?? '0',
                  docId: doc.documentID,
                  nationalId: doc.data['nationalId'] ?? '',
                  gender: doc.data['gender'] ?? '',
                  birthDate: doc.data['birthDate'] ?? '',
                  address: doc.data['address'] ?? '',
                  lat: doc.data['lat'] ?? '',
                  lng: doc.data['lng'] ?? '',
                  phoneNumber: doc.data['phoneNumber'] ?? '',
                  imgUrl: doc.data['imgUrl'] ?? '',
                  email: doc.data['email'] ?? '',
                  aboutYou: doc.data['aboutYou'] ?? '');
              IdTokenResult x =await  user.user.getIdToken(refresh: true);
              _token = x.token;

              final _signInUsingFBorG = json.encode({
                'isSignInUsingFaceBook': 'true',
                'isSignInUsingGoogle': 'false',
              });
              prefs.setString('signInUsingFBorG', _signInUsingFBorG);
              returns = 'true';
            }
          }
          print('D');
          return returns;
      }else{
          GoogleSignInAccount googleSignInAccount =
          await _handleGoogleSignIn();
          final googleAuth = await googleSignInAccount.authentication;
          final googleAuthCred = GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken,
              accessToken: googleAuth.accessToken);
          final  AuthResult user =
          await firebaseAuth.signInWithCredential(googleAuthCred);
          _userId = user.user.uid;
          var patientData = databaseReference.collection("users");
          DocumentSnapshot doc = await patientData.document(_userId).get();
          print('A');
          if(!doc.exists || !doc.data.keys.contains('nationalId')){
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
                imgUrl: user.user.photoUrl??'',
                email:user.user.email??'',
                aboutYou:'');
            await user.user.getIdToken(refresh: true).then((x) {
              _temporaryToken= x.token;
            });
            returns = 'GoToRegister';
          }else{
            print('B');
            _userData = UserData(
                specializationBranch: '',
                specialization: '',
                isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
                name: doc.data['name'] ?? 'Patient',
                points: doc.data['points'] ?? '0',
                docId: doc.documentID,
                nationalId: doc.data['nationalId'] ?? '',
                gender: doc.data['gender'] ?? '',
                birthDate: doc.data['birthDate'] ?? '',
                address: doc.data['address'] ?? '',
                lat: doc.data['lat'] ?? '',
                lng: doc.data['lng'] ?? '',
                phoneNumber: doc.data['phoneNumber'] ?? '',
                imgUrl: doc.data['imgUrl'] ?? '',
                email: doc.data['email'] ?? '',
                aboutYou: doc.data['aboutYou'] ?? '');
            IdTokenResult token=await user.user.getIdToken(refresh: true);
            print('token.token');
            print(token.token);
            _token=token.token;
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

  Future<FacebookLoginResult> _handleFBSignIn() async {
    final facebookLogin = FacebookLogin();
    FacebookLoginResult facebookLoginResult =
        await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("Cancelled");
        break;
      case FacebookLoginStatus.error:
        print("error");
        break;
      case FacebookLoginStatus.loggedIn:
        print("Logged In");
        break;
    }
    return facebookLoginResult;
  }

  Future<GoogleSignInAccount> _handleGoogleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    return googleSignInAccount;
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
          AuthResult result =
              await firebaseAuth.signInWithCredential(credential);
          FirebaseUser user = result.user;

          if (user != null) {
            _userId = user.uid;
            if (_token == null) {
              await firebaseAuth.currentUser().then((user) async {
                if (user != null) {
                  await user.getIdToken().then((token) {
                    print(token.token);
                    _token = token.token;
                  });
                }
              });
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
              DocumentSnapshot doc = await patientData.document(_userId).get();
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
                  specialization: '',
                    specializationBranch: '',
                    isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
                    name: doc.data['name'] ?? 'Nurse',
                    points: doc.data['points'] ?? '0',
                    docId: doc.documentID,
                    nationalId: doc.data['nationalId'] ?? '',
                    gender: doc.data['gender'] ?? '',
                    birthDate: doc.data['birthDate'] ?? '',
                    address: doc.data['address'] ?? '',
                    lat: doc.data['lat'] ?? '',
                    lng: doc.data['lng'] ?? '',
                    phoneNumber: doc.data['phoneNumber'] ?? '',
                    imgUrl: doc.data['imgUrl'] ?? '',
                    email: doc.data['email'] ?? '',
                    aboutYou: doc.data['aboutYou'] ?? '');
                notifyListeners();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
            }
          } else {
            print("Error");
          }
        },
        verificationFailed: (AuthException exception) {
          print('vdbcdbd');
          print(exception.message);
          Toast.show(
              translator.currentLanguage == "en"
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
              AuthCredential credential = PhoneAuthProvider.getCredential(
                  verificationId: verificationId, smsCode: code);
              AuthResult result =
                  await firebaseAuth.signInWithCredential(credential);
              FirebaseUser user = result.user;
              print('etetee');
              if (user != null) {
                _userId = user.uid;
                if (_token == null) {
                  await firebaseAuth.currentUser().then((user) async {
                    if (user != null) {
                      await user.getIdToken().then((token) {
                        print(token.token);
                        _token = token.token;
                      });
                    }
                  });
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
                      await patientData.document(_userId).get();
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
                    _userData = UserData(      isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
specialization: '',
                        specializationBranch: '',
                        name: doc.data['name'],
                        points: doc.data['points'] ?? '0',
                        docId: doc.documentID,
                        nationalId: doc.data['nationalId'] ?? '',
                        gender: doc.data['gender'] ?? '',
                        birthDate: doc.data['birthDate'] ?? '',
                        address: doc.data['address'] ?? '',
                        lat: doc.data['lat'] ?? '',
                        lng: doc.data['lng'] ?? '',
                        phoneNumber: doc.data['phoneNumber'] ?? '',
                        imgUrl: doc.data['imgUrl'] ?? '',
                        email: doc.data['email'] ?? '',
                        aboutYou: doc.data['aboutYou'] ?? '');
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
                  translator.currentLanguage == "en"
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
     users.document(_userId).collection('rating').document('rating').snapshots().listen((rating){
        if(rating.exists) {
          int one = rating.data['1'] == null ? 0 : int.parse(rating.data['1']);
          int two = rating.data['2'] == null ? 0 : int.parse(rating.data['2']);
          int three = rating.data['3'] == null ? 0 : int.parse(rating.data['3']);
          int four = rating.data['4'] == null ? 0 : int.parse(rating.data['4']);
          int five = rating.data['5'] == null ? 0 : int.parse(rating.data['5']);
          totalRatingForNurse =
              (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                  (one + two + three + four + five);
          notifyListeners();
        }
      });

    }
  Future<bool> signInUsingEmailForNurse(
      {String email,
      String password,
      BuildContext context,
      bool isTryToLogin = false}) async {
    print(email);
    print(password);
    AuthResult auth;
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
        IdTokenResult x = await auth.user.getIdToken();
        DocumentSnapshot doc = await users.document(_userId).get();
        if (doc.data['address'] == null ||
            doc.data['phoneNumber'] == null ||
            doc.data['gender'] == null) {
          if (isTryToLogin == false) {
            _userData = UserData(
                name: doc.data['name'] ?? 'Nurse',
                docId: doc.documentID,
                specialization: '',
                specializationBranch: '',
                password: password,
                rating: '0.0',
                nationalId: doc.data['nationalId'] ?? '',
                gender: doc.data['gender'] ?? '',
                birthDate: doc.data['birthDate'] ?? '',
                address: doc.data['address'] ?? '',
                lat: doc.data['lat'] ?? '',
                lng: doc.data['lng'] ?? '',
                phoneNumber: doc.data['phoneNumber'] ?? '',
                imgUrl: doc.data['imgUrl'] ?? '',
                email: email,
                aboutYou: doc.data['aboutYou'] ?? '');
            isLogout = await Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddUserData()));
            isRegisterData = false;
          }
        } else {

          _userData = UserData(
            specializationBranch: doc.data['specializationBranch'] ?? '',
              specialization: doc.data['specialization'] ?? '',
              name: doc.data['name'] ?? 'Nurse',
              points: doc.data['points'].toString() ?? '0',
              docId: doc.documentID,
              nationalId: doc.data['nationalId'].toString() ?? '',
              gender: doc.data['gender'] ?? '',
              birthDate: doc.data['birthDate'] ?? '',
              address: doc.data['address'] ?? '',
              phoneNumber: doc.data['phoneNumber'] ?? '',
              imgUrl: doc.data['imgUrl'] ?? '',
              email: doc.data['email'] ?? '',
              lat: doc.data['lat'] ?? '',
              lng: doc.data['lng'] ?? '',
              aboutYou: doc.data['aboutYou'] ?? '');
          isRegisterData = true;
        }
        if (isTryToLogin) {
          _token = x.token;
        } else {
          _temporaryToken = x.token;
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
    await nurseData.document(_userId).setData({
      "isActive": true,
    },merge: true);
  }
  setUnActive() async {
    var nurseData = databaseReference.collection("nurses");
    await nurseData.document(_userId).setData({
      "isActive": false,
    },merge: true);
  }

  Future<bool>  verifyUniqueId({String id})async{
    var patientCollection = databaseReference.collection("users");
    var docs =await patientCollection.getDocuments();
    bool verify = true;
    if(docs.documents.length != 0){
      for(int i=0; i<docs.documents.length; i++){
        if(docs.documents[i].data['nationalId'] == id){
          verify = false;
          break ;
        }
      }
    }
    return verify;
  }

  Future<bool> updateUserData({
    String name = '',
    File pictureId,
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
    print('rtr');
    var nurseData = databaseReference.collection("nurses");
    var patientData = databaseReference.collection("users");
    DateTime dateTime = DateTime.now();
    String imgUrl = '';
    String idImgUrl = '';
    print('picture');
    print(picture);
    final prefs = await SharedPreferences.getInstance();
    if (!picture.toString().contains('https:')) {
      try {
        var storageReference =  FirebaseStorage.instance
            .ref()
            .child('$name/${path.basename(picture.path)}');
        StorageUploadTask uploadTask = storageReference.putFile(picture);
        await uploadTask.onComplete;
        await storageReference.getDownloadURL().then((fileURL) async {
          imgUrl = fileURL;
        });
      } catch (e) {
        print(e);
      }
    }
    if (_userType == 'nurse') {
      nurseData.document(_userId).setData({
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
      }, merge: true);
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
          StorageUploadTask uploadTask = storageReference.putFile(pictureId);
          await uploadTask.onComplete;
          await storageReference.getDownloadURL().then((fileURL) async {
            idImgUrl = fileURL;
          });
        } catch (e) {
          print(e);
        }
      patientData.document(_userId).setData({
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
      }, merge: true);
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
      doc = await nurseData.document(_userId).get();
    } else {
      doc = await patientData.document(_userId).get();
    }
    _userData = UserData(
      rating: '0.0',
      specializationBranch: doc.data['specializationBranch'] ?? '',
      specialization: doc.data['specialization'] ?? '',
      isVerify:  doc.data['isVerify'] == null? '':doc.data['isVerify'] =='false'?'false':'true',
        name: doc.data['name'] ?? '',
        points: doc.data['points'] ?? '0',
        docId: doc.documentID,
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        lng: doc.data['lng'] ?? '',
        lat: doc.data['lat'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '');
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
