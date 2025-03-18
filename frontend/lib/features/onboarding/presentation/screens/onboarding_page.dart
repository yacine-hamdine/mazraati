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
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _OnboardingContent(data: _pages[index]);
        },
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Skip to last page
                _pageController.jumpToPage(_pages.length - 1);
              },
              child: const Text('Passer'),
            ),
            Row(
              children: List.generate(_pages.length, (idx) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentIndex == idx
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            TextButton(
              onPressed: () {
                if (_currentIndex == _pages.length - 1) {
                  // Navigate to Auth Screen
                  Navigator.pushReplacementNamed(context, '/auth');
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Text(_currentIndex == _pages.length - 1
                  ? 'Commencer'
                  : 'Suivant'),
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
    required this.description,
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
        Image.asset(
          data.image,
          height: 300,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Text(
          data.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
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
