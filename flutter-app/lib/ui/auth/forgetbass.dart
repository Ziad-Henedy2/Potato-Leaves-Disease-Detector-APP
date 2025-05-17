import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage("Please enter your email.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showMessage("Password reset link sent! Check your email.", Colors.green);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage("No account found with this email.", Colors.red);
      } else if (e.code == 'invalid-email') {
        _showMessage("Invalid email format.", Colors.red);
      } else {
        _showMessage(e.message ?? "Something went wrong!", Colors.red);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: color),
    );
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
            // Title
            Text(
              "Forgot Password?",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 10),

            // Subtitle
            Text(
              "Enter your email to receive a password reset link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.green[800]),
            ),
            SizedBox(height: 30),

            // Image
            SizedBox(
              height: 400,
              child: Image.asset("asset/images/forget.jpg"),
            ),
            SizedBox(height: 30),

            // Email Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.green[800]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.email, color: Colors.green[600]),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),

            // Reset Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Send Reset Link", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),

            // Back to Sign In Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Sign In", style: TextStyle(color: Colors.green[700], fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}