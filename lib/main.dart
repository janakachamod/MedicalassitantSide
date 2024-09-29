import 'package:crebrew/models/usermodel.dart';
import 'package:crebrew/screens/wrapper.dart';
import 'package:crebrew/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:crebrew/screens/home/home.dart'; // Import Home
import 'package:provider/provider.dart';
import './dart_pages/MapPage.dart'; // Import MapPage
import './dart_pages/AlertUsersPage.dart'; // Import AlertUsersPage

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
      value:
          AuthService().user, // Assuming AuthService has a stream of UserModel
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Wrapper(),
        debugShowCheckedModeBanner: false, // This line removes the debug banner
      ),
    );
  }
}
