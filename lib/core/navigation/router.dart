// ignore_for_file: lines_longer_than_80_chars

import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/feature/home/mainpage.dart';
import 'package:ai_buddy/feature/welcome/welcome_page.dart';
import 'package:ai_buddy/splash_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) => const MainPage(page: 0),
    ),
    GoRoute(
      path: AppRoute.chat.path,
      builder: (context, state) => const MainPage(page: 1),
    ),
    GoRoute(
      path: AppRoute.welcome.path,
      builder: (context, state) => const WelcomePage(),
    ),
  ],
);
