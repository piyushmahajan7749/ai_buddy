import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  splash('/'),
  login('/login'),
  verifyNumber('/verifynumber/:phoneNumber'),
  home('/home'),
  chat('/chat'),
  welcome('/welcome'),
  onboarding('/onboarding'),
  preferences('/preferences'),
  ;

  const AppRoute(this.path);

  final String path;
}

extension AppRouteNavigation on AppRoute {
  void go(BuildContext context) => context.go(path);

  void push(BuildContext context) => context.push(path);
}
