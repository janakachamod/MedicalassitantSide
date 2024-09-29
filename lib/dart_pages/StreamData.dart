import 'package:flutter/material.dart';
import '../mongodb.dart';

class StreamData extends StatefulWidget {
  const StreamData({super.key});

  @override
  _StreamDataState createState() => _StreamDataState();
}

class _StreamDataState extends State<StreamData> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await MongoDatabase.fetchData();
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MongoDB Data Display'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _data.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  return ListTile(
                    title: Text('ID: ${item['_id']}'), // Display the `_id`
                    subtitle:
                        Text('Value: ${item['value']}'), // Display the `value`
                  );
                },
              ),
      ),
    );
  }
}
