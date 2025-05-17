import 'package:flutter/material.dart';
import 'package:graduation_app/ui/home_screen/components%20/data/change_bass.dart';
import 'package:graduation_app/ui/home_screen/components%20/data/change_email.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UserUpdateScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UserUpdateScreen> {
  final supabase = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();

  File? _image;
  String _profilePicUrl = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    var user = _auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('uid', user.uid)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _nameController.text = response['name'] ?? "";
          _profilePicUrl = response['profile_pic'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _updateUserData() async {
    setState(() => _isLoading = true);
    var user = _auth.currentUser;
    if (user == null) return;

    try {
      // Update name in Supabase
      await supabase.from('users').update({
        'name': _nameController.text,
      }).eq('uid', user.uid);

      // Update profile picture if selected
      if (_image != null) {
        final imagePath = 'profile_pictures/${user.uid}.jpg';
        await supabase.storage.from('profile-pictures').upload(imagePath, _image!, fileOptions: const FileOptions(upsert: true));
        final newPicUrl = supabase.storage.from('profile-pictures').getPublicUrl(imagePath);
        await supabase.from('users').update({'profile_pic': newPicUrl}).eq('uid', user.uid);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated Successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(fontSize: 16)),
            Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Update Profile"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (_profilePicUrl.isNotEmpty ? NetworkImage(_profilePicUrl) : null) as ImageProvider?,
                child: _image == null && _profilePicUrl.isEmpty
                    ? Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 16),
            buildButton("   Change Email", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeEmailScreen()));
            }),
            buildButton("   Change Password", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
            }),
            SizedBox(height: 12),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Save Changes", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}