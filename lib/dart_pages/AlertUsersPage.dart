import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async'; // Import for StreamController and StreamSubscription
import 'package:crebrew/dart_pages/MapPage.dart'; // Import MapPage

class AlertUsersPage extends StatefulWidget {
  @override
  _AlertUsersPageState createState() => _AlertUsersPageState();
}

class _AlertUsersPageState extends State<AlertUsersPage> {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _alertRef =
      FirebaseDatabase.instance.ref().child('Alert');

  final StreamController<DatabaseEvent> _usersController =
      StreamController<DatabaseEvent>.broadcast();
  StreamSubscription<DatabaseEvent>? _alertSubscription;
  StreamSubscription<DatabaseEvent>? _usersSubscription;
  bool _shouldFetchUsers = false;

  @override
  void initState() {
    super.initState();
    _startListeningToAlert();
  }

  void _startListeningToAlert() {
    _alertSubscription = _alertRef.onValue.listen((event) {
      final alertValue = event.snapshot.value as int?;

      if (alertValue == null || alertValue == 0) {
        if (_shouldFetchUsers) {
          setState(() {
            _shouldFetchUsers = false;
          });
          _stopFetchingUsers();
        }
      } else if (alertValue == 1) {
        if (!_shouldFetchUsers) {
          setState(() {
            _shouldFetchUsers = true;
          });
          _startFetchingUsers();
        }
      }
    });
  }

  void _startFetchingUsers() {
    _usersSubscription = _usersRef
        .orderByChild('onlineStatus')
        .equalTo(true)
        .onValue
        .listen((usersEvent) {
      _usersController.add(usersEvent);
    });
  }

  void _stopFetchingUsers() {
    _usersSubscription?.cancel();
    _usersSubscription = null;
    _usersController.addStream(Stream.empty());
  }

  Future<void> _refresh() async {
    if (_shouldFetchUsers) {
      _stopFetchingUsers();
      _startFetchingUsers();
    } else {
      _startFetchingUsers();
    }
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _usersSubscription?.cancel();
    _usersController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<DatabaseEvent>(
          stream: _alertRef.onValue,
          builder: (context, alertSnapshot) {
            if (alertSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (alertSnapshot.hasError) {
              return Center(child: Text('Error: ${alertSnapshot.error}'));
            } else if (!alertSnapshot.hasData ||
                alertSnapshot.data!.snapshot.value == null) {
              return Center(child: Text('No alert data found.'));
            }

            return StreamBuilder<DatabaseEvent>(
              stream:
                  _shouldFetchUsers ? _usersController.stream : Stream.empty(),
              builder: (context, usersSnapshot) {
                if (usersSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (usersSnapshot.hasError) {
                  return Center(child: Text('Error: ${usersSnapshot.error}'));
                } else if (!usersSnapshot.hasData ||
                    usersSnapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No online users found.'));
                }

                final Map<dynamic, dynamic>? usersData = usersSnapshot
                    .data!.snapshot.value as Map<dynamic, dynamic>?;
                final List<Map<String, dynamic>> users = [];
                if (usersData != null) {
                  usersData.forEach((key, value) {
                    if (value is Map) {
                      users.add({
                        'id': key as String,
                        'email': value['email'] as String? ?? '',
                        'name': value['name'] as String? ?? '',
                        'sugar': value['sugar'] as int? ?? 0,
                        'cholesterol': value['cholesterol'] as int? ?? 0,
                        'gender': value['gender'] as int? ?? 1,
                        'age': value['age'] as int? ?? 0,
                        'latitude': value['latitude'] as double? ?? 0.0,
                        'longitude': value['longitude'] as double? ?? 0.0,
                      });
                    }
                  });
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Text(
                            (user['name'] as String).isNotEmpty
                                ? (user['name'] as String).substring(0, 1)
                                : '?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        title: Text(
                          user['name'] as String,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user['email'] as String),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Age: ${user['age']}'),
                            SizedBox(height: 4),
                            Text('Lat: ${user['latitude']}'),
                            Text('Lng: ${user['longitude']}'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPage(
                                initialLatitude: user['latitude'] as double,
                                initialLongitude: user['longitude'] as double,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
