import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:payvor/pages/splash/splash_screen_new.dart';
import 'package:payvor/provider/auth_provider.dart';
import 'package:payvor/provider/firebase_provider.dart';
import 'package:payvor/provider/language_provider.dart';
import 'package:payvor/provider/location_provider.dart';
import 'package:payvor/provider/theme_provider.dart';
import 'package:payvor/viewmodel/auth_view_model.dart';
import 'package:payvor/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

import 'enums/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(
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
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<FirebaseProvider>(
          create: (context) => FirebaseProvider(),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) => LocationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: new SplashScreen(),
//          home: ShowCaseWidget(
//            builder: Builder(
//                builder: (context) => MailPage()
//            ),
//          ),
      ),
    ),
  );
  //});
}

// class Payvor extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//             // Define the default brightness and colors
//             ),
//         // home: new ChatBubbleRight(message: "sample message",profilePic: "sahfhasifhiahsf",isGroup: false,isLiked: false,time: "15:20",chatId: "101",messageId: "555",userName: "user data",),
//         home: new SplashScreen());
//   }
// }
