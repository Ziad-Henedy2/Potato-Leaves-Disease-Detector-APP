import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:graduation_app/ui/auth/signin.dart';
import 'package:graduation_app/ui/home_screen/home_screen.dart';
import 'package:graduation_app/ui/home_screen/components /data/update.dart';
import 'package:http/http.dart' as http;
import 'navbar.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

  String username = "User";
  String email = "user@example.com";
  String profilePicUrl = "";
  List<Map<String, dynamic>> reportHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user == null) return;

    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('uid', user!.uid)
          .maybeSingle();

      if (response != null) {
        setState(() {
          username = response['name'] ?? "User";
          email = response['email'] ?? "user@example.com";
          profilePicUrl = response['profile_pic'] ?? "";
        });

        // Now fetch the reports after the username is updated
        _fetchUserReports();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchUserReports() async {
    setState(() => isLoading = true);

    try {
      // Wait until the username is updated and non-empty
      if (username.isEmpty || username == "User") {
        print('❌ Username is not set yet');
        setState(() => isLoading = false);
        return;
      }

      final files = await supabase.storage
          .from('classified-reports')
          .list(path: '');

      print('🔍 Raw files list: ${files.map((f) => f.name).toList()}');

      if (files.isEmpty) {
        print('📁 No files found in the storage bucket');
        setState(() {
          reportHistory = [];
          isLoading = false;
        });
        return;
      }

      final userFiles = files.where((file) =>
      file.name.toLowerCase().startsWith('${username.toLowerCase()}_') &&
          file.name.toLowerCase().endsWith('.pdf')).toList();

      if (userFiles.isEmpty) {
        print('📂 No user reports found');
        setState(() {
          reportHistory = [];
          isLoading = false;
        });
        return;
      }

      final filteredReports = await Future.wait(userFiles.map((file) async {
        final timestamp = _extractTimestamp(file.name);
        final publicUrl = supabase.storage
            .from('classified-reports')
            .getPublicUrl(file.name);

        return {
          'id': file.name,
          'timestamp': timestamp?.toIso8601String() ?? file.updatedAt ?? DateTime.now().toIso8601String(),
          'report_url': publicUrl,
          'display_name': _getDisplayName(file.name),
        };
      }));

      setState(() {
        reportHistory = filteredReports;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching reports: $e");
      setState(() {
        reportHistory = [];
        isLoading = false;
      });
    }
  }


  DateTime? _extractTimestamp(String filename) {
    try {
      final parts = filename.split('_');
      if (parts.length > 1) {
        final timestampStr = parts[1].split('.').first;
        final seconds = double.tryParse(timestampStr) ?? 0;
        final milliseconds = (seconds * 1000).toInt();  // Convert to milliseconds
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
    return null;
  }

  String _getDisplayName(String filename) {
    final cleanName = filename.split('_').first;
    return '${cleanName[0].toUpperCase()}${cleanName.substring(1)} Report';
  }


  // Function to view the report
  Future<void> _viewReport(String reportUrl) async {
    if (await canLaunch(reportUrl)) {
      await launch(reportUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF viewer')),
      );
    }
  }

  // Format the timestamp to a readable string
  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp); // Assuming timestamp is in ISO 8601 format
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDate;
  }

  // Logout function
  Future<void> _logout() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()), // Redirect to SignIn screen after logging out
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(70))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            GestureDetector(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                backgroundColor: Colors.green[700],
                child: profilePicUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
            ),
            const SizedBox(height: 20),

            // User Info
            Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(email, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // Profile Options
            ProfileOption(icon: Icons.change_circle, title: "Update User Data", onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserUpdateScreen()));
            }),
            ProfileOption(icon: Icons.logout, title: "Logout", onTap: _logout),

            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // Modified Report History Section
            const SizedBox(height: 10),
            const Text("Classification History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            reportHistory.isEmpty
                ? const Text("No history found", style: TextStyle(fontSize: 16, color: Colors.grey))
                : Expanded(
              child: ListView.separated(
                itemCount: reportHistory.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final report = reportHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description, color: Colors.green),
                      ),
                      title: Text(report['display_name'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_formatTimestamp(report['timestamp'])),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.green),
                        onPressed: () => _viewReport(report['report_url']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 3, // Profile tab highlighted
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/about');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/classify');
          }
        },
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({required this.icon, required this.title, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}