import 'package:flutter/material.dart';

import 'countdown_timer.dart';

/// A simple class that displays an alert prompt prior to showing an ad.
class AdDialog extends StatefulWidget {
  final VoidCallback showAd;

  const AdDialog({
    super.key,
    required this.showAd,
  });

  @override
  AdDialogState createState() => AdDialogState();
}

class AdDialogState extends State<AdDialog> {
  final CountdownTimer _countdownTimer = CountdownTimer(5);

  @override
  void initState() {
    _countdownTimer.addListener(() => setState(() {
          if (_countdownTimer.isComplete) {
            Navigator.pop(context);
            widget.showAd();
          }
        }));
    _countdownTimer.start();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('شاهد فيديو لدعم التطبيق'),
          content: Text('يبدأ الفيديو بعد ${_countdownTimer.timeLeft} ثانية...',
              style: const TextStyle(color: Colors.grey)),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'لا شكراً',
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ));
  }

  @override
  void dispose() {
    _countdownTimer.dispose();
    super.dispose();
  }
}
