import 'package:flutter/material.dart';
import 'package:helpme/providers/auth.dart';
import 'package:helpme/providers/home.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/sign_in_and_up/sign_in/sign_in.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LIST_OF_LANGS = ['ar', 'en'];
  LANGS_DIR = 'assets/langs/';
  await translator.init();
  runApp(
    LocalizedApp(
      child: MainClass(),
    ),
  );
}

class MainClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Home()),
//        ChangeNotifierProxyProvider<Auth, Home>(
//          update: (ctx, auth, previousProducts) => Home(
//            auth.getToken(),
//            auth.userId,
//          ),
//          create: (context) => Home(null,null),
//        ),
      ],
      child: App()
    );
  }
}


class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();

}
class _AppState extends State<App> {
  Auth _auth;
  Future<bool> isLoggedIn;
  @override
  void initState() {
    _auth =Provider.of<Auth>(context,listen: false);
    isLoggedIn = _auth.tryToLogin();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: translator.currentLanguage=='en'?'Es3fni':'اسعفنى',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.white,
          cardTheme: CardTheme(
            color: Colors.white,
            margin: EdgeInsets.symmetric(horizontal: 20),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          appBarTheme: AppBarTheme(
            elevation: 2.0,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        home: _auth.isAuth
            ? HomeScreen()
            : FutureBuilder(
            future: isLoggedIn,
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState ==
                  ConnectionState.done &&
                  _auth.isAuth == true) {
                return HomeScreen();
              } else if (authResultSnapshot.connectionState ==
                  ConnectionState.waiting ||
                  authResultSnapshot.connectionState ==
                      ConnectionState.active &&
                      _auth.isAuth == false) {
                return Splash();
              } else {
                return SignIn();
              }
            }),
      )
    ;
  }
}
