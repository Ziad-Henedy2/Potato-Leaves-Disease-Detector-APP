import 'package:flutter/material.dart';
import 'package:graduation_app/ui/auth/signin.dart';
import 'package:graduation_app/ui/auth/signup.dart';
import 'package:graduation_app/ui/auth/welcome.dart';
import 'package:graduation_app/ui/home_screen/components%20/about.dart';
import 'package:graduation_app/ui/home_screen/components%20/classify.dart';
import 'package:graduation_app/ui/home_screen/components%20/data/change_bass.dart';
import 'package:graduation_app/ui/home_screen/components%20/data/change_email.dart';
import 'package:graduation_app/ui/home_screen/components%20/data/update.dart';
import 'package:graduation_app/ui/home_screen/components%20/profile.dart';
import 'package:graduation_app/ui/home_screen/disease/alternaria.dart';
import 'package:graduation_app/ui/home_screen/disease/insect.dart';
import 'package:graduation_app/ui/home_screen/disease/phyto.dart';
import 'package:graduation_app/ui/home_screen/disease/virus.dart';
import 'package:graduation_app/ui/home_screen/home_screen.dart';
import 'package:graduation_app/ui/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://eiriudtlrtygqxfdjchc.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpcml1ZHRscnR5Z3F4ZmRqY2hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1NzA4NzYsImV4cCI6MjA1ODE0Njg3Nn0.nUtDGo3y5ZAmbpIuw_iiOLB60gzVuPqwKpRufoXtIrQ', // Replace with your Supabase Anon Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Potato Leaf Disease Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/welcome': (context) => const Welcome(),
        '/SignIn': (context) => const SignInPage(),
        '/SignUP': (context) => const SignUpPage(),
        '/about': (context) => const AboutScreen(),
        '/classify': (context) => ClassificationPage(),
        '/profile': (context) => const ProfileScreen(),
        '/change_email': (context) => const ChangeEmailScreen(),
        '/change_bass': (context) => const ChangePasswordScreen(),
        '/disease1': (context) => Disease1(),
        '/disease2': (context) =>  Disease2(),
        '/disease3': (context) =>  Disease3(),
        '/disease4': (context) =>  Disease4(),
        '/update': (context) =>  UserUpdateScreen(),

      },
    );
  }
}