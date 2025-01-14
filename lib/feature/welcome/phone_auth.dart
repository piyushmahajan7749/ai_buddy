import 'package:ai_buddy/core/config/assets_constants.dart';
import 'package:ai_buddy/core/util/btnutils.dart';
import 'package:easy_container/easy_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';

bool isNullOrBlank(String? data) => data?.trim().isEmpty ?? true;

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  static const id = 'PhoneAuthScreen';

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String? phoneNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => GoRouter.of(context).go('/welcome'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Lottie.asset(
                  AssetConstants.onboardingAnimation,
                  height: 120,
                  fit: BoxFit.fitHeight,
                ),
                Text(
                  'Login to 9Roof AI',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 80),
                Text(
                  'Enter your phone number',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  "We'll send you a verification code via SMS",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                EasyContainer(
                  elevation: 0,
                  borderRadius: 10,
                  color: Theme.of(context).colorScheme.surface,
                  child: Form(
                    key: _formKey,
                    child: IntlPhoneField(
                      autofocus: true,
                      invalidNumberMessage: 'Invalid Phone Number!',
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 25),
                      onChanged: (phone) => phoneNumber = phone.completeNumber,
                      initialCountryCode: 'IN',
                      flagsButtonPadding: const EdgeInsets.only(right: 10),
                      showDropdownIcon: false,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildOutlinedButton(
                  'Send Verification Code',
                  () async {
                    if (isNullOrBlank(phoneNumber) ||
                        !_formKey.currentState!.validate()) {
                      await Fluttertoast.showToast(
                        msg: 'Please enter a valid phone number!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16,
                      );
                    } else {
                      GoRouter.of(context).go('/verifynumber/$phoneNumber');
                    }
                  },
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
