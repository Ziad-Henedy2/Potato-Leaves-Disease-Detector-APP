import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = "User";
  String userEmail = "user@example.com";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) return;

    try {
      final response = await supabase
          .from('users') // Your Supabase table
          .select()
          .eq('uid', firebaseUser.uid) // Match Firebase user ID
          .maybeSingle();

      if (response != null) {
        setState(() {
          userName = response['name'] ?? "User";
          userEmail = response['email'] ?? "user@example.com";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent reloading the same page

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/classify');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text("Home Screen", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)),
            Text("Scan • Detect • Protect", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(userEmail, style: TextStyle(fontSize: 16)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green[700]),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await firebase_auth.FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/SignIn');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.green[700], size: 30),
                  SizedBox(width: 10),
                  Text("Hello, $userName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),                ],
              ),
            ),
            SizedBox(height: 20),

            // About the Project Section
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Potato Leaf Disease Detection", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      " This app is my graduation project. It uses AI to detect potato leaf diseases from images, helping farmers take early action to protect their crops",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Classification Button
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/classify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text("Let's Classify the Disease", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Disease Types Section
            Center(child: Text("Disease Types the App Can Classify",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black))),

            // Disease Cards
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  DiseaseCard("Insect Damage", "Visible damage due to insect feeding.", "asset/images/Insect154.png", '/disease2'),
                  DiseaseCard("Alternaria Solani", "A fungal disease causing brown spots.", 'asset/images/alternia.jpg', '/disease1'),
                  DiseaseCard("Phytophthora ", "Leads to potato late blight.", "asset/images/phytopthora561.JPG", '/disease3'),
                  DiseaseCard("Virus", "A disease caused by viral infection.", "asset/images/Virus192.JPG", '/disease4'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.black : Colors.green[700]),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: _selectedIndex == 1 ? Colors.black : Colors.green[700]),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: _selectedIndex == 2 ? Colors.black : Colors.green[700]),
            label: 'Classify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 3 ? Colors.black : Colors.green[700]),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Ensure text label color matches
        unselectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }
}


class DiseaseCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String route;

  const DiseaseCard(this.title, this.description, this.imagePath, this.route, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(imagePath, height: 140, fit: BoxFit.cover),
            ),
            Expanded(  // Ensures text and button do not overflow
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Expanded(
                      child: Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, route),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 3,
                        ),
                        child: Text("More Details"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
