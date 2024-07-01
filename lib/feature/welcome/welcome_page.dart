import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/extension/context.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          offset: const Offset(4, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '9Roof AI',
                          style: TextStyle(
                            color: context.colorScheme.background,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          AssetConstants.aiStarLogo,
                          scale: 23,
                        ),
                      ],
                    ),
                  ),
                ),
                Lottie.asset(
                  AssetConstants.onboardingAnimation,
                  height: 200,
                  fit: BoxFit.fitHeight,
                ),
                Text(
                  'Your personal real estate assistant',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      AppRoute.login.go(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colorScheme.onSurface,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      'Get Started',
                      style: context.textTheme.labelLarge!.copyWith(
                        color: context.colorScheme.surface,
                      ),
                    ),
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
