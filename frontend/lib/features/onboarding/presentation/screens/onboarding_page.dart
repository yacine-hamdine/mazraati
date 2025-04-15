import 'package:flutter/material.dart';
import '../widgets/intro_page_view.dart';
import '../widgets/next_button.dart';
import '../widgets/page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding_1.jpg',
      'text': 'Achetez des Produits Frais Directement des Agriculteurs Locaux à Votre Porte.',
    },
    {
      'image': 'assets/images/onboarding_2.jpg',
      'text': 'Découvrez et Commandez des Produits Agricoles Frais en Toute Simplicité.',
    },
    {
      'image': 'assets/images/onboarding_3.jpg',
      'text': 'Connectez-vous aux Agriculteurs pour des Produits Frais et Locaux.',
    },
  ];

  void _skipIntro() {
    Navigator.of(context).pushReplacementNamed('/auth'); 
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
      );
    } else {
      _skipIntro();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Custom AppBar
              Container(
                height: 100,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 100, height: 100), // Placeholder for alignment
                    TextButton(
                      onPressed: _skipIntro,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                        backgroundColor: const Color(0xFFE6EAFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF283891),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page View
              Expanded(
                child: IntroPageView(
                  pageController: _pageController,
                  pages: _pages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
              ),
              PageIndicator(
                currentPage: _currentPage,
                totalPages: _pages.length,
              ),
              const SizedBox(height: 20),
              NextButton(onPressed: _nextPage), // Changed to _nextPage
              const SizedBox(height: 20),
            ],
          ),
          // Logo at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
