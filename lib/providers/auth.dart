import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpme/core/models/device_info.dart';
import 'package:helpme/models/http_exception.dart';
import 'package:helpme/models/user_data.dart';
import 'package:helpme/screens/home_screen.dart';
import 'package:helpme/screens/sign_in_and_up/register_using_phone/verify_code.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Auth with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  static String _token;
  static String userId = '';
  String signInType = '';

  bool get isAuth {
    try {
      firebaseAuth.currentUser().then((user) {
        if (user != null) {
          user.getIdToken().then((token) {
            _token = token.token;
          });
        }
      });
      return _token != null;
    } catch (e) {
      return _token == null;
    }
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

    if(prefs.containsKey('signInUsingPhone')){
  final dataToSignIn = await json
      .decode(prefs.getString('signInUsingPhone')) as Map<String, Object>;
  AuthResult x = await firebaseAuth.signInWithCustomToken(token: dataToSignIn['phoneToken']);
      userId = x.user.uid;
     signInType = 'signInUsingPhone';
    }
    if (_token == null) {
      await firebaseAuth.currentUser().then((user) {
        if (user != null) {
          user.getIdToken().then((token) {
            _token = token.token;
          });
        }
      });
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
               await firebaseAuth.currentUser().then((user) async{
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
               Navigator.of(context).pushReplacement(MaterialPageRoute(
                   builder: (context) =>HomePage() ));
             }
           } else {
             print("Error");
           }
         },
         verificationFailed: (AuthException exception) {
           print('vdbcdbd');
           print(exception.message);
           Toast.show(translator.currentLanguage == "en"
               ? "you are send more requests please try again later":'لقد قمت بطلب الكود اكثر من مره من فضلك حاول فى وق لاحق', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
         },
         codeSent: (String verificationId, [int forceResendingToken]) {
           getCode(String code)async{
             print('etey$code');
             try {
               AuthCredential credential =
               PhoneAuthProvider.getCredential(
                   verificationId: verificationId,
                   smsCode: code);
               AuthResult result =
               await firebaseAuth.signInWithCredential(credential);
               FirebaseUser user = result.user;
               print('etetee');
               if (user != null) {
                 userId = user.uid;
                 if (_token == null) {
                   await firebaseAuth.currentUser().then((user) async{
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
                   Navigator.of(context).pushReplacement(MaterialPageRoute(
                       builder: (context) =>HomePage() ));
                 }

               } else {
                 print("Error");
               }
             }catch (e){
               print(e);
               Toast.show(translator.currentLanguage == "en"
                   ? "invalid verification code":'الكود الذى ادخلته غير صحيح', context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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
