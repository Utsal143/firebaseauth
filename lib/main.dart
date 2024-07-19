import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterlogin/screens/home_screen.dart';
import 'package:flutterlogin/screens/login_screen.dart';
import 'package:flutterlogin/screens/registration_screen.dart'; // Import the registration screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login UI',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/register': (context) => RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final User user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) {
              return HomeScreen(user: user);
            },
          );
        }
        return null;
      },
    );
  }
}
