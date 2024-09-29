import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crebrew/constants/colors.dart';
import 'package:crebrew/services/auth.dart';
import 'package:crebrew/dart_pages/MapPage.dart'; // Import MapPage
import 'package:crebrew/dart_pages/AlertUsersPage.dart'; // Import AlertUsersPage

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final DatabaseReference _alertRef =
      FirebaseDatabase.instance.ref().child('Alert');
  final DatabaseReference _sensorPin1Ref =
      FirebaseDatabase.instance.ref().child('sensorpin1');
  final DatabaseReference _sensorPin2Ref =
      FirebaseDatabase.instance.ref().child('sensorpin2');
  final DatabaseReference _vibratorRef =
      FirebaseDatabase.instance.ref().child('vibrator');
  final DatabaseReference _buzzerRef =
      FirebaseDatabase.instance.ref().child('buzzer');
  final DatabaseReference _relayRef =
      FirebaseDatabase.instance.ref().child('relay');

  bool _alertStatus = false;
  bool _spaceAvailable = false;
  bool _vibratorStatus = false;
  bool _buzzerStatus = false;
  bool _relayStatus = false;

  @override
  void initState() {
    super.initState();
    _startListeningToFirebase();
  }

  void _startListeningToFirebase() {
    _alertRef.onValue.listen((event) {
      final alertValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _alertStatus = alertValue == 1;
        _updateBuzzer();
        _updateVibrator();
      });
    });

    _sensorPin1Ref.onValue.listen((event) {
      final sensorPin1Value = event.snapshot.value as int? ?? 0;
      _updateSpaceAvailability(sensorPin1Value: sensorPin1Value);
    });

    _sensorPin2Ref.onValue.listen((event) {
      final sensorPin2Value = event.snapshot.value as int? ?? 0;
      _updateSpaceAvailability(sensorPin2Value: sensorPin2Value);
    });

    _vibratorRef.onValue.listen((event) {
      final vibratorValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _vibratorStatus = vibratorValue == 1;
      });
    });

    _buzzerRef.onValue.listen((event) {
      final buzzerValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _buzzerStatus = buzzerValue == 1;
      });
    });

    _relayRef.onValue.listen((event) {
      final relayValue = event.snapshot.value as int? ?? 0;
      setState(() {
        _relayStatus = relayValue == 1;
      });
    });
  }

  void _updateSpaceAvailability({int? sensorPin1Value, int? sensorPin2Value}) {
    final spaceAvailable = (sensorPin1Value == 1 || sensorPin2Value == 1);
    setState(() {
      _spaceAvailable = spaceAvailable;
      _updateVibrator();
      _updateBuzzer();
    });
  }

  void _updateBuzzer() {
    final buzzerValue = (_alertStatus && _spaceAvailable) ? 1 : 0;
    _buzzerRef.set(buzzerValue); // Update Firebase
    setState(() {
      _buzzerStatus = buzzerValue == 1;
    });
  }

  void _updateVibrator() {
    final vibratorValue = _alertStatus ? 1 : 0;
    _vibratorRef.set(vibratorValue); // Update Firebase
    setState(() {
      _vibratorStatus = vibratorValue == 1;
    });
  }

  void _toggleRelay() async {
    final newValue = !_relayStatus ? 1 : 0;
    await _relayRef.set(newValue);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleAlert() async {
    final newValue = !_alertStatus ? 1 : 0;
    await _alertRef.set(newValue);
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages for the bottom navigation
    final List<Widget> _pages = [
      HomePage(
        alertStatus: _alertStatus,
        spaceAvailable: _spaceAvailable,
        buzzerStatus: _buzzerStatus,
        vibratorStatus: _vibratorStatus,
        onBuzzerToggle: _toggleBuzzer,
        onVibratorToggle: _toggleVibrator,
        onAlertToggle: _toggleAlert, // Pass the toggle function to HomePage
      ),
      MapPage(initialLatitude: 0.0, initialLongitude: 0.0),
      AlertUsersPage(),
    ];

    return Scaffold(
      backgroundColor: bgBlack,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: bgBlack,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bgBlack),
            ),
            onPressed: () async {
              final AuthService _auth = AuthService();
              await _auth.signOut(); // Ensure the sign out is awaited
            },
            child: const Icon(
              Icons.exit_to_app, // Better icon for sign out
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Alert Users',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleRelay,
        child: Icon(_relayStatus ? Icons.toggle_on : Icons.toggle_off),
        backgroundColor: _relayStatus ? Colors.green : Colors.red,
        tooltip: 'Toggle Relay',
      ),
    );
  }

  void _toggleBuzzer() async {
    final newValue = !_buzzerStatus ? 1 : 0;
    await _buzzerRef.set(newValue);
  }

  void _toggleVibrator() async {
    final newValue = !_vibratorStatus ? 1 : 0;
    await _vibratorRef.set(newValue);
  }
}

// Define the HomePage widget
class HomePage extends StatelessWidget {
  final bool alertStatus;
  final bool spaceAvailable;
  final bool buzzerStatus;
  final bool vibratorStatus;
  final VoidCallback onBuzzerToggle;
  final VoidCallback onVibratorToggle;
  final VoidCallback onAlertToggle; // Added the Alert toggle callback

  HomePage({
    required this.alertStatus,
    required this.spaceAvailable,
    required this.buzzerStatus,
    required this.vibratorStatus,
    required this.onBuzzerToggle,
    required this.onVibratorToggle,
    required this.onAlertToggle, // Pass the Alert toggle function
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Home Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatusCard("Alert Status", alertStatus ? "Active" : "Inactive"),
          const SizedBox(height: 20),
          _buildStatusCard("Space Availability",
              spaceAvailable ? "Available" : "Not Available"),
          const SizedBox(height: 20),
          _buildControlCard("Buzzer", buzzerStatus, onBuzzerToggle),
          const SizedBox(height: 20),
          _buildControlCard("Vibrator", vibratorStatus, onVibratorToggle),
          const SizedBox(height: 20),
          _buildControlCard(
              "Alert", alertStatus, onAlertToggle), // Added Alert switch
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(String title, bool status, VoidCallback onToggle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: status,
            onChanged: (val) {
              onToggle();
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
