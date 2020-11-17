import 'package:flutter/material.dart';
import 'package:payvor/pages/appintro/app_intro.dart';
import 'package:payvor/pages/dashboard/dashboard.dart';
import 'package:payvor/provider/language_provider.dart';
import 'package:payvor/provider/theme_provider.dart';
import 'package:payvor/viewmodel/auth_view_model.dart';
import 'package:payvor/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';
import 'enums/flavor.dart';
import 'package:oktoast/oktoast.dart';


void main() {
  //for check life cycle
  WidgetsFlutterBinding.ensureInitialized();

//  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.landscapeLeft])
  //    .then((_) async {
  runApp(
    /*
      * MultiProvider for top services that do not depends on any runtime values
      * such as user uid/email.
       */
    MultiProvider(providers: [
      Provider<Flavor>.value(value: Flavor.dev),
      ChangeNotifierProvider<AuthViewModel>(
        create: (context) => AuthViewModel(),
      ),
      ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(),
      ),
      ChangeNotifierProvider<LanguageProvider>(
        create: (context) => LanguageProvider(),
      ),
      ChangeNotifierProvider<ThemeProvider>(
        create: (context) => ThemeProvider(),
      ),
    ], child: Payvor()),
  );
  //});
}

class Payvor extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Material(child: AppIntroPage()),
        "/home": (_) => Material(child: DashBoardScreen()),
      },
    ));
  }
}
