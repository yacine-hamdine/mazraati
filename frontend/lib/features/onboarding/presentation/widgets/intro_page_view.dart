// lib/widgets/intro_page_view.dart
import 'package:flutter/material.dart';

class IntroPageView extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, String>> pages;
  final Function(int) onPageChanged;

  const IntroPageView({
    super.key,
    required this.pageController,
    required this.pages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: pages.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.transparent, // Make the background transparent
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage(pages[index]['image']!),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  pages[index]['text']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}