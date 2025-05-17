import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the custom navbar
import 'package:graduation_app/ui/home_screen/home_screen.dart';
import 'classify.dart';
import 'profile.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent reloading the same page

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
      // Already on About Screen
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClassificationPage()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About the App", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset("asset/logo/logo.png", height: 200, width: double.infinity, fit: BoxFit.fitHeight),
              ),
              SizedBox(height: 14),
              Center(child: Text("Potato Leaf Disease Detection", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
              SizedBox(height: 5),
              Text("This app is my graduation project, designed to help farmers detect potato leaf diseases quickly and accurately. It uses a deep learning model based on a modified ResNet for classification and a U-Net for detecting affected areas in leaf images.Users can upload a photo of a potato leaf, and the app will analyze it, identify the disease, and highlight infected areas. It also provides details about the disease and a YouTube video with a recommended solution.The goal is to assist farmers in early disease detection, reduce crop losses, and improve overall yield. The app is powered by a Flask API and Firebase for authentication and data storage.",
                style: TextStyle(fontSize: 15.7, color: Colors.grey[700]),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 2),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Key Features", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700])),
                    SizedBox(height: 10),
                    FeatureTile(icon: Icons.camera_alt, text: "Image-based Disease Detection"),
                    FeatureTile(icon: Icons.lightbulb, text: "AI-Powered Analysis"),
                    FeatureTile(icon: Icons.notifications, text: "Instant Results & Recommendations"),
                    FeatureTile(icon: Icons.eco, text: "Supports Sustainable Farming"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text("Developed by Ziad Henedy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green[700])),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureTile({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 28),
          SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
