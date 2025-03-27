import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';

class CheckInTimer extends StatefulWidget {
  final Duration initialDuration;

  const CheckInTimer({Key? key, required this.initialDuration})
      : super(key: key);

  @override
  _CheckInTimerState createState() => _CheckInTimerState();
}

class _CheckInTimerState extends State<CheckInTimer> {
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check-In Rate")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DurationPicker(
              duration: _duration,
              onChange: (val) => setState(() => _duration = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_duration);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
