import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  Future<void> _onIntroEnd(BuildContext context) async {
    // scheduleDailyNotification(_time);
    Navigator.pop(context);
    // getIt<SessionState>().getIsOnboarding
    //     ? await _storeReminderTimePref(_time)
    //     : auth.currentUser != null
    //         ? await DbServicePreferences(uid: auth.currentUser!.uid)
    //             .updateReminders(_time)
    //         : null;
  }

  Widget _buildDatePicker(Function onIntroEnd) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Select Time to receive notifications',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Render inline widget
                  showPicker(
                    isInlinePicker: true,
                    elevation: 8,
                    value: Time.fromTimeOfDay(_time, null),
                    onChange: onTimeChanged,
                    minuteInterval: TimePickerInterval.FIVE,
                    accentColor: Theme.of(context).colorScheme.primary,
                    unselectedColor: Theme.of(context).colorScheme.secondary,
                    isOnChangeValueMode: true,
                  ) as Widget,
                ],
              ),
              const SizedBox(height: 10),
              buildElevatedButton('Save', onIntroEnd),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton(String text, Function onDone) {
    return ElevatedButton(
      onPressed: () {
        onDone(context);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDatePicker(_onIntroEnd);
  }
}
