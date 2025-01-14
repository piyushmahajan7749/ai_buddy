// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class SessionState extends ChangeNotifier {
  // ignore: use_late_for_private_fields_and_variables
  bool? _isOnboarding = false;

  // ignore: avoid_positional_boolean_parameters, use_setters_to_change_properties
  void setIsOnboarding(bool val) {
    _isOnboarding = val;
  }

  bool get getIsOnboarding {
    return _isOnboarding!;
  }
}
