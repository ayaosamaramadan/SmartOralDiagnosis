import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
                Positioned.fill(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color.fromARGB(255, 255, 255, 255),
                        BlendMode.srcATop,
                      ),
                      child: Opacity(
                        opacity: 0.3,
                        child: Image.asset('assets/doodle.png', fit: BoxFit.cover),
                      ),
                    ),
                ),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildNavBar(context),
                const SizedBox(height: 40),
                _buildHeroSection(context),
                const SizedBox(height: 40),
                _buildContactRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("OralScan",
              style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent)),
          PopupMenuButton<int>(
            icon: Icon(Icons.menu, color: Colors.white, size: 32),
            color: Colors.black87,
            itemBuilder: (context) => [
              PopupMenuItem(
          value: 0,
          child: _navText("SERVICES"),
              ),
              PopupMenuItem(
          value: 1,
          child: _navText("PORTFOLIO"),
              ),
              PopupMenuItem(
          value: 2,
          child: _navText("ABOUT US"),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
          value: 3,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              // Add your CONTACT US logic here
            },
            child: const Text("CONTACT US"),
          ),
              ),
              PopupMenuItem(
          value: 4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Add your OUR TEAM logic here
            },
            child: const Text("OUR TEAM"),
          ),
              ),
            ],
            onSelected: (value) {
              // Handle menu item selection if needed
            },
          ),
        ],
        
      ),
    );
  }

  Widget _navText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image first with rounded left and bottom edges
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(170),
              bottomRight: Radius.circular(30),
            ),
            child: Image.asset(
              "assets/home.jpg",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          // Heading
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Scan your Mouth ",
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 176, 201, 246)),
                ),
                TextSpan(
                  text: "With AI to detect ",
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 255, 255, 255)),
                ),
                TextSpan(
                  text: "Oral and dental diseases",
                  style: GoogleFonts.poppins(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Use our smart tool to analyze mouth and dental images and detect early signs of oral problems quickly and accurately. Keep your mouth healthy and your smile bright with ease.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
            
              label: const Text("Start Scan Now", style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.4 * 255).round()),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _contactInfo(Icons.location_on, "Visit Us", "Cairo, Egypt"),
            _contactInfo(Icons.phone, "Give Us a Call", "(+20) 71 419 2082"),
            _contactInfo(Icons.email, "Send Ussage",
                "info.egy@gmail.com"),
          ],
        ),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
