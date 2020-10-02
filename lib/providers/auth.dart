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

class Auth with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
   String _token;
  String _userId = '';

  String get userId => _userId;


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
    return _token != null;
  }

  String getToken() {
    print(_token);
    return _token;
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
      if (dataToSignIn['isSignInUsingFaceBook'] == true) {
        await signInUsingFBorG(type: 'FB').then((x) {
          if (x=='true') {
            signInType = 'signInUsingFBorG';
          }
        });
      }
      if (dataToSignIn['isSignInUsingGoogle'] == true) {
        await signInUsingFBorG(type: 'G').then((x) {
          if (x=='true') {
            signInType = 'signInUsingFBorG';
          }
        });
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
      AuthResult x = await firebaseAuth.signInWithCustomToken(
          token: dataToSignIn['phoneToken']);
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
  Future<String> signInUsingFBorG({String type, BuildContext context}) async {
    final prefs = await SharedPreferences.getInstance();
    String returns='true';
    _userType = 'patient';
    try {
      switch (type) {
        case "FB":
          FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
          final accessToken = facebookLoginResult.accessToken.token;
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
         //   final facebookAuthCred =
              //  FacebookAuthProvider.getCredential(accessToken: accessToken);
           // final user =
//                await firebaseAuth.signInWithCredential(facebookAuthCred);
//            _userId = user.user.uid;
//         email: googleSignIn.currentUser.email,
//    name: googleSignIn.currentUser.displayName,
//    profilePicURL: googleSignIn.currentUser.photoUrl,
//    gender: await getGender()
           // FacebookLogin facebookLogin = FacebookLogin();
            //user.additionalUserInfo.profile.
            //createAccount(imgUrl: ,name: user.user.displayName,email: user.user.email,id: user.user.uid)
//            print("User : " + user.user.displayName);
//            final _signInUsingFBorG = json.encode({
//              'isSignInUsingFaceBook': true,
//              'isSignInUsingGoogle': false,
//            });
//            prefs.setString('signInUsingFBorG', _signInUsingFBorG);
            //  notifyListeners();
            returns ='false';
          } else
            //notifyListeners();
            returns ='false';
          break;
        case "G":
          try {
            GoogleSignInAccount googleSignInAccount =
                await _handleGoogleSignIn();
            final googleAuth = await googleSignInAccount.authentication;
            final googleAuthCred = GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken);
            final user =
                await firebaseAuth.signInWithCredential(googleAuthCred);
            _userId = user.user.uid;
            var patientData = databaseReference.collection("users");
            DocumentSnapshot doc = await patientData.document(_userId).get();
            if(!doc.exists || !doc.data.keys.contains('nationalId')){
              _userData = UserData(
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
              await user.user.getIdToken().then((x) {
                _temporaryToken= x.token;
              });
              returns = 'GoToRegister';
            }else{
              _userData = UserData(
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
              await user.user.getIdToken().then((x) {
                _token = x.token;
              });
              final _signInUsingFBorG = json.encode({
                'isSignInUsingFaceBook': false,
                'isSignInUsingGoogle': true,
              });
              prefs.setString('signInUsingFBorG', _signInUsingFBorG);
              returns = 'true';
            }
          } catch (error) {
            returns= 'false';
          }
      }
      return returns;
    } catch (e) {
      returns ='false';
      return returns;
    }
  }

  Future<FacebookLoginResult> _handleFBSignIn() async {
    FacebookLogin facebookLogin = FacebookLogin();
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
              prefs.setString('signInUsingPhone', _signInUsingPhone);
              print('rytryhrrhr');
              DocumentSnapshot doc = await patientData.document(_userId).get();
              if (!doc.exists) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AddUserData()));
              } else {
                _userData = UserData(
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
                  print('wtrwetetetetyyyyyyyyyyyyyyyyyyyy');
                  prefs.setString('signInUsingPhone', _signInUsingPhone);
                  DocumentSnapshot doc =
                      await patientData.document(_userId).get();
                  if (!doc.exists) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => AddUserData()));
                  } else {
                    _userData = UserData(
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

  Future<bool> signInUsingEmailForNurse(
      {String email,
      String password,
      BuildContext context,
      bool isTryToLogin = false}) async {
    print(email);
    print(password);
    AuthResult auth;
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
        if (isTryToLogin) {
          _token = x.token;
        } else {
          _temporaryToken = x.token;
        }
        _userType = 'nurse';
        DocumentSnapshot doc = await users.document(_userId).get();
        print(doc.data);
        if (doc.data['address'] == null ||
            doc.data['phoneNumber'] == null ||
            doc.data['gender'] == null) {
          if (isTryToLogin == false) {
            _userData = UserData(
                name: doc.data['name'] ?? 'Nurse',
                docId: doc.documentID,
                password: password,
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
  Future<bool> updateUserData({
    String name = '',
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
    String imgUrl = '';
    print('picture');
    print(picture);
    final prefs = await SharedPreferences.getInstance();
    if (!picture.toString().contains('https:')) {
      try {
        var storageReference = FirebaseStorage.instance
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
        'points': '0'
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
      patientData.document(_userId).setData({
        'name': name,
        'address': location,
        'lat':lat??'',
        'lng':lng??'',
        'phoneNumber': phoneNumber,
        'birthDate': birthDate,
        'nationalId': nationalId,
        'gender': gender,
        'imgUrl': picture.toString().contains('https:')?picture:imgUrl,
        'points': '0'
      }, merge: true);
      _token = _temporaryToken;
      if(this.phoneNumber ==null){
        final _signInUsingFBorG = json.encode({
          'isSignInUsingFaceBook': false,
          'isSignInUsingGoogle': true,
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
        name: doc.data['name'] ?? 'Nurse',
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
