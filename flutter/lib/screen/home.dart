import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/theme_toggle.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    return Scaffold(
      drawer: _buildSideMenu(context, cs),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        backgroundColor: cs.primary,
        tooltip: 'Chat',
        child: Icon(Icons.chat_bubble, color: cs.onPrimary),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    appColors.gradientStart,
                    appColors.gradientMiddle,
                    appColors.gradientEnd,
                  ]
                : const [
                    Color(0xFFB3E5FC),
                    Color(0xFF64B5F6),
                    Color(0xFF1976D2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildNavBar(context, cs),
                const SizedBox(height: 40),
                _buildHeroSection(context, cs, ts),
                const SizedBox(height: 40),
                _buildContactRow(context, cs, ts),
                const SizedBox(height: 32),
                _buildFindClinicsSection(context, cs, ts),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- NAVBAR ----------------
  Widget _buildNavBar(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "OralScan",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: cs.onSurface, size: 32),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SIDE MENU ----------------
  // ---------------- SIDE MENU ----------------
Drawer _buildSideMenu(BuildContext context, ColorScheme cs) {
  return Drawer(
    backgroundColor: cs.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [cs.primary, cs.secondary]
                  : [cs.primary.withOpacity(0.8), cs.primary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "OralScan",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const ThemeToggle(),
            ],
          ),
        ),
        _buildDrawerItem(context, cs, "Home", Icons.home, () {
          Navigator.pushNamed(context, '/');
        }),
        _buildDrawerItem(context, cs, "Diseases & Conditions", Icons.medical_services, () {
          Navigator.pushNamed(context, '/Alldisease');
        }),
        _buildDrawerItem(context, cs, "Edit_pofile", Icons.edit, () {
          Navigator.pushNamed(context, '/editProfile');
        }),
        _buildDrawerItem(context, cs, "About Us", Icons.info_outline, () {
          // Add About navigation
        }),
        const Divider(),
        ListTile(
          leading: Icon(Icons.contact_page, color: cs.primary),
          title: Text("Contact Us", style: TextStyle(color: cs.onSurface)),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.login, color: cs.primary),
          title: Text("Login", style: TextStyle(color: cs.onSurface)),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    ),
  );
}


  Widget _buildDrawerItem(
      BuildContext context, ColorScheme cs, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: cs.primary),
      title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 16)),
      onTap: onTap,
    );
  }

  // ---------------- HERO SECTION ----------------
  Widget _buildHeroSection(BuildContext context, ColorScheme cs, TextTheme ts) {
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
                    color: cs.primary.withOpacity(0.9),
                  ),
                ),
                TextSpan(
                  text: "With AI to detect ",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: cs.onBackground,
                  ),
                ),
                TextSpan(
                  text: "Oral and dental diseases",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Use our smart tool to analyze mouth and dental images and detect early signs of oral problems quickly and accurately.",
            style: ts.bodyMedium?.copyWith(
              color: cs.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              icon: const Icon(Icons.camera_alt),
              label: Text(
                "Start Scan Now",
                style: TextStyle(color: cs.onPrimary, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CONTACT ROW ----------------
  Widget _buildContactRow(BuildContext context, ColorScheme cs, TextTheme ts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _contactInfo(Icons.location_on, "Visit Us", "Cairo, Egypt", cs, ts),
            _contactInfo(Icons.phone, "Give Us a Call", "(+20) 71 419 2082", cs, ts),
            _contactInfo(Icons.email, "Send Message", "info.egy@gmail.com", cs, ts),
          ],
        ),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String title, String subtitle, ColorScheme cs, TextTheme ts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: cs.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: ts.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        Text(
          subtitle,
          style: ts.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  // ---------------- FIND CLINICS ----------------
  Widget _buildFindClinicsSection(BuildContext context, ColorScheme cs, TextTheme ts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outline.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withOpacity(0.08),
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
                    children: [
                      Text(
                        'Find Clinics on the Map',
                        style: ts.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Locate nearby clinics and specialists, compare reviews, and get directions quickly.',
                        style: ts.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.7)),
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
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.onPrimary.withOpacity(0.2),
                        radius: 16,
                        child: Icon(Icons.location_on, color: cs.onPrimary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text('Open Map', style: ts.labelLarge?.copyWith(color: cs.onPrimary)),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: cs.onPrimary),
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
}
