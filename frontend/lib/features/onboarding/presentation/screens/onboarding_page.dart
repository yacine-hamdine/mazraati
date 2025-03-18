import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/onboarding_1.jpg',
      title: 'Achetez vos Produits Frais',
      description: 'Accédez aux produits locaux directement auprès des agriculteurs.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_2.jpg',
      title: 'Soutenez les Agriculteurs',
      description: 'Encouragez et conservez nos agriculteurs et le terroir local.',
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_3.jpg',
      title: 'Commandez Facilement',
      description: 'Profitez de prix abordables et d’une livraison rapide.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          // App Logo
          Image.asset(
            'assets/images/logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _OnboardingContent(data: _pages[index]);
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _pageController.jumpToPage(_pages.length - 1),
              child: Text('Passer', style: TextStyle(color: Colors.green[700])),
            ),
            Row(
              children: List.generate(_pages.length, (idx) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentIndex == idx ? Colors.green[700] : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            TextButton(
              onPressed: () {
                if (_currentIndex == _pages.length - 1) {
                  Navigator.pushReplacementNamed(context, '/auth');
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Text(
                _currentIndex == _pages.length - 1 ? 'Commencer' : 'Suivant',
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;

  _OnboardingData({
    required this.image,
    required this.title,
/*************  ✨ Codeium Command ⭐  *************/
  /// Returns a column of widgets that display the onboarding content given in
  /// [data].
  ///
  /// The widgets are arranged in the following order:
  ///
  /// 1. An image loaded from the asset path given in [data.image].
  /// 2. A large title text with bold font style, centered and given by
  ///    [data.title].
  /// 3. A smaller description text, centered and given by [data.description].
  ///
  /// The widgets are spaced vertically with [SizedBox] widgets and horizontally
  /// with [Padding] widgets. The image is constrained to have a height of 300
  /// logical pixels and its width is shrunk to fit the available space.
/******  a97f2194-6f8f-46da-aea5-5868e72bf43d  *******/    required this.description,
  });
}

class _OnboardingContent extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingContent({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Image.asset(
            data.image,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          data.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
