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
      child: App(),
    ),
  );
}


class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Home>(
          update: (ctx, auth, previousProducts) => Home(
            auth.getToken(),
            auth.userId,
          ),
          create: (context) => Home(null,null),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Es3fni',
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
          home:
          auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
              future: auth.tryToLogin(),
              builder: (ctx, authResultSnapshot) {
                if (authResultSnapshot.connectionState ==
                    ConnectionState.done &&
                    auth.isAuth) {
                  return HomeScreen();
                } else if (authResultSnapshot.connectionState ==
                    ConnectionState.waiting ||
                    authResultSnapshot.connectionState ==
                        ConnectionState.active &&
                        !auth.isAuth) {
                  return Splash();
                } else {
                  return SignIn();
                }
              }),
        ),
      ),
    );
  }
}
