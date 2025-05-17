import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_app/ui/home_screen/components%20/navbar.dart';
import 'package:graduation_app/ui/home_screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:graduation_app/ui/home_screen/disease/alternaria.dart';
import 'package:graduation_app/ui/home_screen/disease/insect.dart';
import 'package:graduation_app/ui/home_screen/disease/phyto.dart';
import 'package:graduation_app/ui/home_screen/disease/virus.dart';
import 'package:graduation_app/ui/home_screen/components /report.dart';


class ClassificationPage extends StatefulWidget {
  @override
  _ClassificationPageState createState() => _ClassificationPageState();
}

class _ClassificationPageState extends State<ClassificationPage> {
  File? _image;
  String? _diseaseName;
  String? _diseaseInfo;
  bool _isHealthy = false;
  bool _isLoading = false;
  bool _showMoreButton = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _diseaseName = null;
        _diseaseInfo = null;
        _isHealthy = false;
        _showMoreButton = false;
      });
    }
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/predict'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(await response.stream.bytesToString());
      String disease = jsonResponse["disease"];

      setState(() {
        _diseaseName = disease;
        _isHealthy = disease == "Healthy";
        _diseaseInfo = _getDiseaseInfo(disease);
        _isLoading = false;
        _showMoreButton = !_isHealthy;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _getDiseaseInfo(String disease) {
    switch (disease) {
      case "Alternaria Solani":
        return "Risk: 70% severe, 30% recoverable.\n A fungal disease causing dark brown spots.\n Use fungicides like Mancozeb.";
      case "Insect Damage":
        return "Risk: 40% severe, 60% recoverable.\n Your plant has insect damage.\n Use neem oil or insecticidal soap.";
      case "Phytophthora Infestans":
        return "Risk: 90% severe, 10% recoverable.\n Causes potato late blight.\n Use copper-based fungicides and crop rotation.";
      case "Virus":
        return "Risk: 80% severe, 20% recoverable.\n Infected with a virus.\n Remove infected plants and control aphids.";
      case "Healthy":
        return "Risk: 0% severe, 100% healthy.\n Great! Your plant is healthy. Keep up the good care!";
      default:
        return "Unknown condition. Please consult an expert.";
    }
  }

  void _navigateToDiseasePage() {
    if (_diseaseName != null) {
      Widget page;
      switch (_diseaseName) {
        case "Alternaria Solani":
          page = Disease1();
          break;
        case "Insect Damage":
          page = Disease2();
          break;
        case "Phytophthora Infestans":
          page = Disease3();
          break;
        case "Virus":
          page = Disease4();
          break;
        default:
          return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  void _navigateToReportPage() {
    if (_image != null && _diseaseName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPage(
            imagePath: _image!.path, // Pass the image path
            diseaseName: _diseaseName!,
            diseaseInfo: _diseaseInfo!, // Pass the classified disease name
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Potato Disease Classification", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, height: 200, fit: BoxFit.cover),
            )
                : Text("No image selected", style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.upload),
                  label: Text("Upload Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Take Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            _image != null && !_isLoading
                ? ElevatedButton(
              onPressed: _classifyImage,
              child: Text("Classify Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            )
                : (_isLoading ? CircularProgressIndicator() : Container()),

            SizedBox(height: 8),

            if (_diseaseName != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _isHealthy ? Colors.transparent : Colors.red, // Red border only for diseased images
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Text(
                        _diseaseName!,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _isHealthy ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _diseaseInfo ?? "",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      if (_isHealthy) // Only show the icon if healthy
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                    ],
                  ),
                ),
              ),

            if (_showMoreButton)
              SizedBox(height: 20),
            if (_showMoreButton)
              ElevatedButton(
                onPressed: _navigateToDiseasePage,
                child: Text("Learn More About $_diseaseName"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),


            if (_showMoreButton)
              ElevatedButton(
                onPressed: _navigateToReportPage,
                child: Text("Generate Report"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/about');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}