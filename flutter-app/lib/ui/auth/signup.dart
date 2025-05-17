import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias for Firebase User
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Alias for Supabase User

import 'package:graduation_app/ui/auth/signin.dart';
import '../home_screen/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final supabase.SupabaseClient supabaseClient = supabase.Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = false;

  // Function to Sign Up
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase Authentication - Create User
      firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        // Store User Data in Supabase
        await supabaseClient.from('users').upsert({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': user.email,
          'profile_pic': user.photoURL ?? '',
        });

        // Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully Signed Up!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Sign Up", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green[700])),
            SizedBox(height: 20),
            SizedBox(height: 300, child: Image.asset("asset/images/up2.png")),
            SizedBox(height: 30),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: TextStyle(color: Colors.green[800]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.person, color: Colors.green[600]),
              ),
              style: TextStyle(color: Colors.green[900]),
            ),
            SizedBox(height: 20),

            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.green[800]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email, color: Colors.green[600]),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: Colors.green[900]),
            ),
            SizedBox(height: 20),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock, color: Colors.green[600]),
              ),
              style: TextStyle(color: Colors.green[900]),
            ),
            SizedBox(height: 20),

            // Confirm Password Field
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock, color: Colors.green[600]),
              ),
              style: TextStyle(color: Colors.green[900]),
            ),
            SizedBox(height: 30),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            // Already have an account? Sign In
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
              },
              child: Text(
                "Already have an account? Sign In",
                style: TextStyle(color: Colors.green[700], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}