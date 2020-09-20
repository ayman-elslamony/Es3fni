import 'dart:convert';
import 'dart:io';
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
  String userId = '';
  String signInType = '';
  String _userType = 'patient';
  UserData _userData = UserData(
      name: 'ayman',
      docId: '12345',
      points: '20',
      email: 'ayman17@gmail',
      address: 'mansoura',
      phoneNumber: '01145523795',
      gender: 'male',
      imgUrl:
          'https://w0.pngwave.com/png/246/366/computer-icons-avatar-user-profile-man-avatars-png-clip-art.png');

  set setUserType(String type) {
    _userType = type;
  }

  String get getUserType {
    return _userType;
  }
  String _temporaryToken='';
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
        await signInUsingFBorG('FB').then((x) {
          if (x) {
            signInType = 'signInUsingFBorG';
          }
        });
      }
      if (dataToSignIn['isSignInUsingGoogle'] == true) {
        await signInUsingFBorG('G').then((x) {
          if (x) {
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
      userId = x.user.uid;
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

  Future<void> createRecord({String userId, UserData userData}) async {
    var users = databaseReference.collection("users");
    DocumentSnapshot doc = await users.document(userId).get();
    if (!doc.exists) {
      await users.document(userId).setData({
        'name': userData.name,
        'email': userData.email,
        'imgUrl': userData.imgUrl,
      });
    }
  }

  Future<bool> editProfile(
      {String type,
      String address,
      String phone,
      File picture,
        String aboutYou
      }) async {
    var nurseData = databaseReference.collection("nurses");

    try{
      if(type == 'image'){
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
        nurseData.document(userId).setData({
          'imgUrl': imgUrl,
        },
            merge: true
        );
      }
      if(type == 'Another Info'){
        nurseData.document(userId).setData({
          'aboutYou':aboutYou
        },
            merge: true
        );
      }
      if(type == 'Address'){
        nurseData.document(userId).setData({
          'address': address,
        },
            merge: true
        );
      }
      if(type == 'Phone Number'){
        nurseData.document(userId).setData({
          'phoneNumber': phone,
        },
            merge: true
        );
      }
      DocumentSnapshot doc = await nurseData.document(userId).get();
      _userData = UserData(
          name: doc.data['name'] ?? 'Nurse',
          docId: doc.documentID,
          nationalId: doc.data['nationalId'] ?? '',
          gender: doc.data['gender'] ?? '',
          birthDate: doc.data['birthDate'] ?? '',
          address: doc.data['address'] ?? '',
          phoneNumber: doc.data['phoneNumber'] ?? '',
          imgUrl: doc.data['imgUrl'] ?? '',
          email: doc.data['email'] ?? '',
          aboutYou: doc.data['aboutYou'] ?? ''
      );
      notifyListeners();
      return true;
    }catch (e){
      print(e);
      return false;
    }
  }

  createAccount(
      {String name,
      String email,
      String imgUrl,
      String id,
      bool isSignUsingEmail = false}) async {
    if (isSignUsingEmail) {
      await createRecord(
          userId: id,
          userData: UserData(email: email, name: name, imgUrl: imgUrl));
    } else {
      await createRecord(
          userId: id,
          userData: UserData(email: email, name: name, imgUrl: imgUrl));
    }
  }

  Future<bool> signInUsingFBorG(String type) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      switch (type) {
        case "FB":
          FacebookLoginResult facebookLoginResult = await _handleFBSignIn();
          final accessToken = facebookLoginResult.accessToken.token;
          if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
            final facebookAuthCred =
                FacebookAuthProvider.getCredential(accessToken: accessToken);
            final user =
                await firebaseAuth.signInWithCredential(facebookAuthCred);
            userId = user.user.uid;
//         email: googleSignIn.currentUser.email,
//    name: googleSignIn.currentUser.displayName,
//    profilePicURL: googleSignIn.currentUser.photoUrl,
//    gender: await getGender()
            FacebookLogin facebookLogin = FacebookLogin();
            //user.additionalUserInfo.profile.
            //createAccount(imgUrl: ,name: user.user.displayName,email: user.user.email,id: user.user.uid)
            print("User : " + user.user.displayName);
            final _signInUsingFBorG = json.encode({
              'isSignInUsingFaceBook': true,
              'isSignInUsingGoogle': false,
            });
            prefs.setString('signInUsingFBorG', _signInUsingFBorG);
            //  notifyListeners();
            return true;
          } else
            //notifyListeners();
            return false;
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
            userId = user.user.uid;
            await createAccount(
                imgUrl: user.user.photoUrl,
                name: user.user.displayName,
                email: user.user.email,
                id: user.user.uid);
            final _signInUsingFBorG = json.encode({
              'isSignInUsingFaceBook': false,
              'isSignInUsingGoogle': true,
            });
            prefs.setString('signInUsingFBorG', _signInUsingFBorG);
            return true;
          } catch (error) {
            return false;
          }
      }
    } catch (e) {
      return false;
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

  Future<String> signInUsingPhone(
      {String phone, BuildContext context, DeviceInfo infoWidget}) async {
    final prefs = await SharedPreferences.getInstance();
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          print('dfbfbff');
          AuthResult result =
              await firebaseAuth.signInWithCredential(credential);
          FirebaseUser user = result.user;

          if (user != null) {
            userId = user.uid;
            if (_token == null) {
              await firebaseAuth.currentUser().then((user) async {
                if (user != null) {
                  await user.getIdToken().then((token) {
                    print(token.token);
                    _token = token.token;
                  });
                }
              });
              print(userId);
              print(_token);
              final _signInUsingPhone = json.encode({
                'phoneToken': _token,
              });
              prefs.setString('signInUsingPhone', _signInUsingPhone);
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
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
                userId = user.uid;
                if (_token == null) {
                  await firebaseAuth.currentUser().then((user) async {
                    if (user != null) {
                      await user.getIdToken().then((token) {
                        print(token.token);
                        _token = token.token;
                      });
                    }
                  });
                  print(userId);
                  print(_token);
                  final _signInUsingPhone = json.encode({
                    'phoneToken': _token,
                  });
                  prefs.setString('signInUsingPhone', _signInUsingPhone);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomeScreen()));
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
    try {
      auth = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (auth != null) {
        userId = auth.user.uid;
        IdTokenResult x = await auth.user.getIdToken();
        if(isTryToLogin){
          _token = x.token;
        }else{
          _temporaryToken = x.token;
        }
        _userType = 'nurse';
        DocumentSnapshot doc = await users.document(userId).get();
        print(doc.data);
        if (doc.data['address'] == null ||
            doc.data['phoneNumber'] == null ||
            doc.data['gender'] == null) {
          if (isTryToLogin == false) {
            _userData = UserData(
              name: doc.data['name'] ?? 'Nurse',
              docId: doc.documentID,
              nationalId: doc.data['nationalId'] ?? '',
              gender: doc.data['gender'] ?? '',
              birthDate: doc.data['birthDate'] ?? '',
              address: doc.data['address'] ?? '',
              phoneNumber: doc.data['phoneNumber'] ?? '',
              imgUrl: doc.data['imgUrl'] ?? '',
              email: doc.data['email'] ?? '',
              aboutYou: doc.data['aboutYou'] ?? ''
            );
            await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AddUserData()));
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
              aboutYou: doc.data['aboutYou'] ?? ''
          );
          isRegisterData = true;
        }
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('signInUsingEmail')) {
          final _signInUsingEmail = json.encode({
            'email': email,
            'password': password,
          });
          prefs.setString('signInUsingEmail', _signInUsingEmail);
        }
      }
      if(isTryToLogin == false){
        notifyListeners();
      }
      return isRegisterData;
    } catch (e) {
      print('eee');
      print(e);
      throw HttpException(e.code);
    }
  }

  Future<bool> updateNurseData({
    String name = '',
    String location = '',
    String phoneNumber = '',
    String aboutYou = '',
    String birthDate = '',
    String gender = '',
    File picture,
  }) async {
    var nurseData = databaseReference.collection("nurses");
    String imgUrl = '';
    if (picture != null) {
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
    nurseData.document(userId).setData({
      'name': name,
      'address': location,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'gender': gender,
      'imgUrl': imgUrl,
      'aboutYou':aboutYou
    },
    merge: true
    );
    _token =_temporaryToken;
    notifyListeners();
    return true;
  }

  Future<bool> logout() async {
    try {
      firebaseAuth.signOut();
      _token = null;
      userId = null;
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }
}
