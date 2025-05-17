import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Disease4 extends StatefulWidget {
  @override
  _Disease1State createState() => _Disease1State();
}

class _Disease1State extends State<Disease4> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    const videoUrl = 'https://www.youtube.com/watch?v=QkVaRMhynRo';
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)], // red gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Text(
            'Virus',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection('asset/images/Virus192.JPG'),
                _buildTitleSection('🦠 Virus'),
                _buildInfoSection('📌 Overview',
                    'Viral infections in potato plants are caused by pathogens like Potato Virus Y (PVY), Potato Virus X (PVX), and others. These viruses spread mainly through insect vectors like aphids and by using infected seed tubers, leading to reduced yield and tuber quality.'),
                _buildInfoSection('🚨 Symptoms',
                    '• Mosaic or mottled light and dark green patterns on leaves\n• Leaf curling, crinkling, or distortion\n• Stunted plant growth\n• Yellowing or chlorosis along leaf veins\n• Poor tuber size and uneven development'),
                _buildInfoSection('🛠 Treatment Suggestions',
                    '1. Use certified virus-free seed potatoes\n2. Control aphids and other insect vectors with appropriate insecticides\n3. Rogue (remove) and destroy infected plants immediately\n4. Practice crop rotation and avoid planting in previously infected soil\n5. Clean tools and machinery to prevent mechanical transmission'),
                _buildVideoPlayer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String imagePath) => Center(
    child: Container(
      height: 350,
      width: 350,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.red,
          width: 6,
        ),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );

  Widget _buildTitleSection(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.red.shade900, // deep red
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _buildInfoSection(String title, String content) => Card(
    color: Colors.red.shade50,
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 6,
    shadowColor: Colors.red.shade200,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildVideoPlayer() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎥 Treatment Video Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}