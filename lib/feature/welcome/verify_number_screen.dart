import 'package:ai_buddy/core/database/dbuser.dart';
import 'package:ai_buddy/core/navigation/route.dart';
import 'package:ai_buddy/feature/welcome/widgets/custom_loader.dart';
import 'package:ai_buddy/feature/welcome/widgets/pin_input.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({
    required this.phoneNumber,
    super.key,
  });
  static const id = 'VerifyPhoneNumberScreen';

  final String phoneNumber;

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen>
    with WidgetsBindingObserver {
  bool isKeyboardVisible = false;

  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  // scroll to bottom of screen, when pin input field is in focus.
  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber,
        signOutOnSuccessfulVerification: false,
        sendOtpOnInitialize: true,
        linkWithExistingUser: false,
        autoRetrievalTimeOutDuration: const Duration(seconds: 60),
        otpExpirationDuration: const Duration(seconds: 60),
        onCodeSent: () {
          Fluttertoast.showToast(
            msg: 'OTP sent!',
          );
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          await Fluttertoast.showToast(
            msg: 'Phone number verified successfully!',
          );

          // ignore: use_build_context_synchronously
          final user = userCredential.user;

          if (user != null) {
            final dbService = DbServiceUser(uid: user.uid);
            // Check if user prefs already exist
            final prefsExist = await dbService.userPrefsExist();

            if (!prefsExist) {
              // Only create if they don't exist
              await dbService.createUserPref();
            }
          }
          AppRoute.home.go(context);
        },
        onLoginFailed: (authException, stackTrace) {
          switch (authException.code) {
            case 'invalid-phone-number':
              // invalid phone number
              Fluttertoast.showToast(
                msg: 'Invalid phone number!',
              );
            case 'invalid-verification-code':
              // invalid otp entered
              Fluttertoast.showToast(
                msg: 'The entered OTP is invalid!',
              );
            // handle other error codes
            default:
              Fluttertoast.showToast(
                msg: 'Something went wrong!',
              );
            // handle error further if needed
          }
        },
        onError: (error, stackTrace) {
          Fluttertoast.showToast(
            msg: 'An error occurred!',
          );
        },
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              title: const Text('Verify Phone Number'),
              actions: [
                if (controller.codeSent)
                  TextButton(
                    onPressed: controller.isOtpExpired
                        ? () async {
                            await controller.sendOTP();
                          }
                        : null,
                    child: Text(
                      controller.isOtpExpired
                          ? 'Resend'
                          : '${controller.otpExpirationTimeLeft.inSeconds}s',
                      style: const TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                const SizedBox(width: 5),
              ],
            ),
            body: controller.isSendingCode
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomLoader(),
                      SizedBox(height: 50),
                      Center(
                        child: Text(
                          'Sending OTP',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    controller: scrollController,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        // ignore: lines_longer_than_80_chars
                        "We've sent a verification code to ${widget.phoneNumber}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      if (controller.isListeningForOtpAutoRetrieve)
                        const Column(
                          children: [
                            CustomLoader(),
                            SizedBox(height: 40),
                            Text(
                              'Listening for OTP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            Text('OR', textAlign: TextAlign.center),
                            Divider(),
                          ],
                        ),
                      const SizedBox(height: 15),
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      PinInputField(
                        length: 6,
                        onFocusChange: (hasFocus) async {
                          if (hasFocus) {
                            await _scrollToBottomOnKeyboardOpen();
                          }
                        },
                        onSubmit: (enteredOtp) async {
                          final verified =
                              await controller.verifyOtp(enteredOtp);
                          if (verified) {
                            // number verify success
                            // will call onLoginSuccess handler
                            // ignore: use_build_context_synchronously
                            AppRoute.home.go(context);
                          } else {
                            // phone verification failed
                            await Fluttertoast.showToast(
                              msg: 'Phone verification failed!',
                            );
                          }
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
