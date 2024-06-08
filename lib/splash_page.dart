// ignore_for_file: use_build_context_synchronously

import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
  }

  Future<void> _navigateToNextPage() async {
    final String? apiKey = await secureStorage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      AppRoute.welcome.go(context);
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 1200), () async {
        AppRoute.home.go(context);
      });
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
