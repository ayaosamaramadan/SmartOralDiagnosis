import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/theme_toggle.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: Colors.blueAccent,
        tooltip: 'Chat',
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColors.gradientStart,
              appColors.gradientMiddle,
              appColors.gradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavBar(context),
              const SizedBox(height: 40),
              _buildHeroSection(context),
              const SizedBox(height: 40),
              _buildContactRow(context),
              const SizedBox(height: 32),
              _buildFindClinicsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindClinicsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade900.withAlpha((0.8 * 255).round())
                : Colors.white.withAlpha((0.9 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.06 * 255).round()),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Find Clinics on the Map',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Locate nearby clinics and specialists, compare reviews, and get directions quickly.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/map');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        radius: 16,
                        child: Icon(Icons.location_on, color: Colors.white, size: 18),
                      ),
                      SizedBox(width: 10),
                      Text('Open Map', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "OralScan",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Row(
            children: [
              const ThemeToggle(), // زر تفعيل Dark/Light mode
              const SizedBox(width: 12),
              PopupMenuButton<int>(
                icon: const Icon(Icons.menu, color: Colors.white, size: 32),
                color: Colors.black87,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 0, child: _navText("HOME")),
                  PopupMenuItem(value: 1, child: _navText("DISEASE & CONDITIONS")),
                  PopupMenuItem(value: 2, child: _navText("ABOUT US")),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 3,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
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
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text("LOGIN"),
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      Navigator.pushNamed(context, '/');
                      break;
                    case 1:
                      Navigator.pushNamed(context, '/Alldisease');
                      break;
                    case 2:
                      // Add about us navigation here
                      break;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Scan your Mouth ",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 176, 201, 246),
                  ),
                ),
                TextSpan(
                  text: "With AI to detect ",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "Oral and dental diseases",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              label: const Text(
                "Start Scan Now",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
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
            _contactInfo(Icons.email, "Send Ussage", "info.egy@gmail.com"),
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
