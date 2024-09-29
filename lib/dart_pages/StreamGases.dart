import 'package:flutter/material.dart';
import '../mongodb.dart';

class StreamGases extends StatefulWidget {
  const StreamGases({super.key});

  @override
  _StreamGasesState createState() => _StreamGasesState();
}

class _StreamGasesState extends State<StreamGases> {
  List<Map<String, dynamic>> _gasesData = [];

  @override
  void initState() {
    super.initState();
    _fetchGasesData();
  }

  Future<void> _fetchGasesData() async {
    final gasesData =
        await MongoDatabase.fetchGasesData(); // Fetch gases data from MongoDB
    setState(() {
      _gasesData = gasesData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MongoDB Gases Data Display'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchGasesData,
        child: _gasesData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _gasesData.length,
                itemBuilder: (context, index) {
                  final item = _gasesData[index];
                  return ListTile(
                    title: Text(
                        'Gas Type: ${item['gasType']}'), // Display the gas type
                    subtitle: Text(
                        'Concentration: ${item['value']} ppm'), // Display the concentration
                  );
                },
              ),
      ),
    );
  }
}
