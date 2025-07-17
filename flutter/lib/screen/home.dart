import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 1, 20),
        elevation: 0,
        title: const Text(
          'SMOD',
          style: TextStyle(
            color: Color.fromARGB(212, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.5,
            fontStyle: FontStyle.normal,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'about', child: Text('About')),
            ],
            onSelected: (value) {
              
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F050D), Color(0xFF001F54)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 255, 255, 255),
                  BlendMode.srcATop,
                ),
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/doodle.png', fit: BoxFit.cover),
                ),
              ),
            ),

            
            Column(
              children: [
                const SizedBox(height: 70), 

                SizedBox(
                  width: 400,
                  height: 310,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/home.webp',
                          width: 290,
                          height: 290,
                          fit: BoxFit.cover,
                        ),
                      ),

                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          const double radius = 160;
                          const int teethCount = 4;
                          return Stack(
                            children: List.generate(teethCount, (index) {
                              final angle = _rotationAnimation.value +
                                  (2 * math.pi / teethCount) * index;
                              return Transform.translate(
                                offset: Offset(
                                  radius * math.cos(angle),
                                  radius * math.sin(angle),
                                ),
                                child: Image.asset(
                                  'assets/teeth.png',
                                  width: 25,
                                  height: 25,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), 
                const Text(
                  'Welcome to Oral Diagnosis!',
                  style: TextStyle(
                    color: Color(0xFFB3C7F9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your smart assistant for oral health analysis.',
                  style: TextStyle(
                    color: Color(0xFF8FA1C7),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30), 
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF233A6A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () {
                  
                  },
                  child: const Text(
                    'Start Diagnosis',
                    style: TextStyle(
                      color: Color(0xFFF5F7FB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ],
              ),
           
          ],
        ),
      ),
    );
  }
}
