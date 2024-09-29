import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RealtimePage extends StatefulWidget {
  const RealtimePage({super.key});

  @override
  _RealtimePageState createState() => _RealtimePageState();
}

class _RealtimePageState extends State<RealtimePage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref(); // Reference to the root of your database
  int _bpm = 0;
  bool _alert = false;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    // Listen for BPM value changes
    _dbRef.child('BPM').onValue.listen((event) {
      DataSnapshot bpmSnapshot = event.snapshot;
      print('BPM Snapshot: ${bpmSnapshot.value}');
      setState(() {
        _bpm = bpmSnapshot.value is int ? bpmSnapshot.value as int : 0;
      });
    });

    // Listen for alert value changes
    _dbRef.child('alert').onValue.listen((event) {
      DataSnapshot alertSnapshot = event.snapshot;
      print('Alert Snapshot: ${alertSnapshot.value}');
      setState(() {
        // Treat the alert value as an integer and interpret 1 as true and 0 as false
        int alertValue =
            alertSnapshot.value is int ? alertSnapshot.value as int : 0;
        _alert = alertValue == 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BPM: $_bpm', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Alert: ${_alert ? 'Activated' : 'Deactivated'}',
                style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
