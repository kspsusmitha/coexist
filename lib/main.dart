import 'package:co_exist/location_provider.dart';
import 'package:co_exist/previous_incidents_view.dart';
import 'package:co_exist/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'choose_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_view.dart';

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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasData) {
              // User is logged in
              return const ChooseMode();
            }
            
            // User is not logged in
            return const LoginView();
          },
        ),
      ),
    ),
  );
}