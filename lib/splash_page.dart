// ignore_for_file: use_build_context_synchronously

import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNextPage();
    });
  }

  Future<void> _navigateToNextPage() async {
    // Add a delay to show the splash screen for a moment
    await Future<void>.delayed(const Duration(seconds: 2));

    // Check if the user is signed in
    final bool isSignedIn = auth.currentUser != null;

    if (isSignedIn) {
      AppRoute.home.go(context);
    } else {
      AppRoute.welcome.go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              AssetConstants.onboardingAnimation,
              height: 200,
              fit: BoxFit.fitHeight,
            ),
            Text(
              '9Roof AI',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}
