import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


class ReportPage extends StatefulWidget {
  final String imagePath;
  final String diseaseName;
  final String diseaseInfo;

  const ReportPage({
    Key? key,
    required this.imagePath,
    required this.diseaseName,
    required this.diseaseInfo,
  }) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isSubmitting = false;
  String? _statusMessage;
  String? _reportUrl;
  String _timestamp = DateTime.now().toString();
  String _userName = "Unknown User";
  String _userEmail = "Unknown Email";
  String _userId = "";
  String _location = "Unknown Location";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('users')
          .select('name, email')
          .eq('uid', user.uid)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _userEmail = response['email'] ?? "No Email";
          _userName = response['name'] ?? "No Name";
          _userId = user.uid;
        });
      } else {
        // handle the error case if user not found in Supabase
        setState(() {
          _userEmail = "No Email";
          _userName = "No Name";
          _userId = user.uid;
        });
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isSubmitting = true;
      _statusMessage = "📝 Generating Report...";
    });

    try {
      // Convert image to Base64
      File imageFile = File(widget.imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var generateReportResponse = await http.post(
        Uri.parse('http://10.0.2.2:5000/generate_report'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "disease_name": widget.diseaseName,
          "image_base64": base64Image,  // Send image as Base64
          "user_id": _userId,
          "user_data": {
            "name": _userName,
            "email": _userEmail,
            "location": _location
          }
        }),
      );

      var reportJson = jsonDecode(generateReportResponse.body);

      if (generateReportResponse.statusCode == 200) {
        setState(() {
          _reportUrl = reportJson["report_url"];
          _statusMessage = "✅ Report Generated!.";
        });
      } else {
        setState(() => _statusMessage = "❌ Failed to generate report.");
      }
    } catch (e) {
      setState(() => _statusMessage = "❌ Error: ${e.toString()}");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  void _openReport() async {
    if (_reportUrl == null) {
      setState(() => _statusMessage = "❌ Error: Report URL not found.");
      return;
    }

    try {
      // Check if the URL can be launched
      if (await canLaunchUrl(Uri.parse(_reportUrl!))) {
        await launchUrl(
          Uri.parse(_reportUrl!),
          mode: LaunchMode.externalApplication, // Opens in default browser/app
        );
      } else {
        setState(() => _statusMessage = "❌ No app found to open PDF.");
      }
    } catch (e) {
      setState(() => _statusMessage = "❌ Failed to open PDF: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Generate Report",style: TextStyle(fontSize: 25, color: Colors.white)),
        backgroundColor: Colors.red[800],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(widget.imagePath), height: 280, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.red[800],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      widget.diseaseName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.red[800],
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person, color: Colors.white),
                        SizedBox(width: 10),
                        Text("User Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const Divider(color: Colors.white70),
                    ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.white),
                      title: Text(_userName, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.white),
                      title: Text(_userEmail, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.white),
                      title: Text(_timestamp, style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text("Generate Report", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 20),

            if (_reportUrl != null)
              ElevatedButton.icon(
                onPressed: _openReport,
                label: const Text("View Report", style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),

            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _statusMessage!.contains("✅") ? Colors.green[700] : Colors.red[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


