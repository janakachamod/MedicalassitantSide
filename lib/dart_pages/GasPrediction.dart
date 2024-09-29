import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GasPrediction extends StatefulWidget {
  const GasPrediction({Key? key}) : super(key: key);

  @override
  _GasPredictionState createState() => _GasPredictionState();
}

class _GasPredictionState extends State<GasPrediction> {
  TextEditingController no2Controller = TextEditingController();
  TextEditingController coController = TextEditingController();
  TextEditingController nh3Controller = TextEditingController();
  TextEditingController tolueneController = TextEditingController();
  String predictionResult = '';

  Future<void> predictGas() async {
    final apiUrl =
        'http://192.168.43.122:5001/predict'; // Replace with your API URL
    var data = {
      'NO2': no2Controller.text,
      'CO': coController.text,
      'NH3': nh3Controller.text,
      'Toluene': tolueneController.text,
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      setState(() {
        predictionResult = json.decode(response.body)['prediction'];
      });
    } else {
      setState(() {
        predictionResult = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gas Prediction'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: no2Controller,
              decoration: InputDecoration(labelText: 'NO2'),
            ),
            TextField(
              controller: coController,
              decoration: InputDecoration(labelText: 'CO'),
            ),
            TextField(
              controller: nh3Controller,
              decoration: InputDecoration(labelText: 'NH3'),
            ),
            TextField(
              controller: tolueneController,
              decoration: InputDecoration(labelText: 'Toluene'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                predictGas();
              },
              child: Text('Predict'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Prediction Result: $predictionResult',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
