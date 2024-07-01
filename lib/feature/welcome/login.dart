import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/core/util/auth.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.showClose,
    super.key,
  });
  final bool showClose;
  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthService auth = AuthService();

  Future<String?> _authUser(LoginData data) async {
    final response = await auth.emailSignIn(data.name, data.password);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: FlutterLogin(
          theme: LoginTheme(
            primaryColor: Theme.of(context).colorScheme.onBackground,
            pageColorLight: Theme.of(context).colorScheme.background,
            accentColor: Theme.of(context).colorScheme.primary,
            buttonStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.background,
                ),
            cardTheme: CardTheme(
              color: Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.symmetric(vertical: 80),
            ),
            errorColor: Theme.of(context).colorScheme.primary,
            switchAuthTextColor: Theme.of(context).colorScheme.onPrimary,
            authButtonPadding: const EdgeInsets.symmetric(vertical: 20),
            titleStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
            textFieldStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
            footerTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
            buttonTheme: LoginButtonTheme(
              elevation: 2,
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: '9Roof AI',
          logo: 'assets/images/9Roof-icon.png',
          onLogin: _authUser,
          hideForgotPasswordButton: true,
          initialAuthMode: AuthMode.login,
          onRecoverPassword: auth.sendPasswordResetEmail,
          userValidator: (value) {
            if (!value!.contains('@')) {
              return "Invalid email: must contain '@'";
            }
            return null;
          },
          passwordValidator: (value) {
            if (value!.isEmpty) {
              return 'Password is empty';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          navigateBackAfterRecovery: true,
          messages: LoginMessages(
            loginButton: 'Log In',
            signupButton: 'Sign up',
            recoverPasswordButton: 'Send',
            forgotPasswordButton: 'Forgot password?',
            confirmPasswordError: "Passwords don't match",
            recoverPasswordDescription:
                'We will send a link to this email account',
            confirmSignupSuccess: 'Welcome!',
            flushbarTitleError: '',
            signUpSuccess: 'Signed up successfully!',
          ),
          onSubmitAnimationCompleted: () {
            AppRoute.home.go(context);
          },
        ),
      ),
    );
  }
}
