import 'package:flutter/material.dart';
import 'package:async/async.dart' show RestartableTimer;
import 'package:soba_app/navigation.dart' show BottomBar;
import 'package:soba_app/main.dart' hide MainApp;

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});
  
  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  void _timeout() {
    // TODO: Send push
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    RestartableTimer checkinTimer = RestartableTimer(const Duration(minutes: 15), _timeout);

    return Scaffold(
      bottomNavigationBar: BottomBar(scheme: scheme, selected: 0),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 2.5*dfInsets, bottom: dfInsets),
            decoration: BoxDecoration(
              gradient: gradientOrange,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(dfInsets),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0)
                    )
                  ),
                  child: Text(
                    'Organization Name',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Hi, Name',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+60111 783 6655',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Are you in an emergency?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: scheme.primary),
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.red.shade300,
            child: Icon(Icons.error_outline, color: Colors.white, size: 120),
          ),
          Expanded(child: SizedBox.shrink()),
          Container(
            margin: EdgeInsets.all(dfInsets),
            padding: EdgeInsets.all(dfInsets),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(dfRadius),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.access_alarm, color: scheme.primary, size: 100),
                      ],
                    ),
                    SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          'Next check-in:',
                          style: TextStyle(color: scheme.primary, fontSize: 32),
                        ),
                        Container(
                          width: 221, // TODO: Adapt to fill space
                          padding: EdgeInsets.all(dfInsets),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(dfRadius),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ]
                          ),
                          child: Text(
                            '07:12', // TODO: Read from checkinTimer
                            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: scheme.onPrimary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(dfInsets),
                    shadowColor: Colors.black12,
                    backgroundColor: Colors.grey,
                  ),
                  child: Text('Check In', style: TextStyle(fontSize: 40, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}