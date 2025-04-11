import 'package:co_exist/location_provider.dart';
import 'package:co_exist/previous_incidents_view.dart';
import 'package:co_exist/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'choose_mode.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    
    MultiProvider(
      providers: [
     ChangeNotifierProvider(create: (context) => LocationProvider()..fetchLocations()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // showPerformanceOverlay: true,
        home: ChooseMode(),)));
}