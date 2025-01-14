// ignore_for_file: lines_longer_than_80_chars

import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/feature/home/mainpage.dart';
import 'package:ai_buddy/feature/onboarding/onboardingscreen.dart';
import 'package:ai_buddy/feature/welcome/phone_auth.dart';
import 'package:ai_buddy/feature/welcome/verify_number_screen.dart';
import 'package:ai_buddy/feature/welcome/welcome_page.dart';
import 'package:ai_buddy/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoute.onboarding.path,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoute.login.path,
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: AppRoute.verifyNumber.path,
      builder: (context, state) => VerifyPhoneNumberScreen(
        phoneNumber: state.pathParameters['phoneNumber'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoute.home.path,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 1200),
          child: const MainPage(page: 0),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity:
                  CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: AppRoute.chat.path,
      builder: (context, state) => const MainPage(page: 1),
    ),
    GoRoute(
      path: AppRoute.welcome.path,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoute.preferences.path,
      builder: (context, state) => const MainPage(page: 3),
    ),
  ],
);
