import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IotWeather extends StatefulWidget {
  final String? mlResult;
  final String? mlConfidence;

  const IotWeather({Key? key, this.mlResult, this.mlConfidence})
      : super(key: key);

  @override
  _IotWeatherState createState() => _IotWeatherState();
}

class _IotWeatherState extends State<IotWeather> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for health prediction inputs
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController bpmController = TextEditingController();
  final TextEditingController fbsController = TextEditingController();
  final TextEditingController cholController = TextEditingController();

  String? predictionResult;
  String? _iotPrediction;
  double? _iotConfidence;

  // Function to predict health using the health prediction API
  Future<void> predictHealth() async {
    if (_formKey.currentState?.validate() ?? false) {
      final apiUrl =
          'http://192.168.43.122:5000/predict'; // Replace with your API URL
      var data = {
        'age': int.parse(ageController.text),
        'sex': int.parse(sexController.text),
        'BPM': int.parse(bpmController.text),
        'fbs': int.parse(fbsController.text),
        'chol': int.parse(cholController.text),
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            predictionResult = responseData['prediction'].toString();
          });
        } else {
          setState(() {
            predictionResult = 'Error: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          predictionResult = 'Error: $e';
        });
      }
    }
  }

  // Function to predict weather using the IoT weather API
  Future<void> _predict() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse(
            'http://192.168.43.122:5002/predictiot'), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Temperature': double.tryParse(ageController.text),
          'Humidity': double.tryParse(sexController.text),
          'Wind Speed': double.tryParse(bpmController.text),
          'Atmospheric Pressure': double.tryParse(fbsController.text),
        }),
      );

      final responseData = json.decode(response.body);
      setState(() {
        _iotPrediction = responseData['prediction'];
        _iotConfidence = responseData['confidence'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double mlConf =
        widget.mlConfidence != null ? double.parse(widget.mlConfidence!) : 0.0;
    String bestWeatherCondition = widget.mlResult ?? "Unknown";
    double bestConfidence = mlConf;

    if (_iotPrediction != null && _iotConfidence != null) {
      if (_iotConfidence! > mlConf) {
        bestWeatherCondition = _iotPrediction!;
        bestConfidence = _iotConfidence!;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Weather Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Health Prediction Fields
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: sexController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Sex (1: Male, 0: Female)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your sex';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: bpmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'BPM'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your BPM';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: fbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Fasting Blood Sugar (fbs)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your fasting blood sugar level';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: cholController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Cholesterol Level (chol)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your cholesterol level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: predictHealth,
                child: const Text('Predict Health'),
              ),
              const SizedBox(height: 20),
              if (predictionResult != null)
                Text(
                  'Health Prediction Result: $predictionResult',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _predict,
                child: const Text('Predict Weather'),
              ),
              const SizedBox(height: 20),
              if (_iotPrediction != null && _iotConfidence != null)
                Text(
                  'IoT Prediction: $_iotPrediction\nIoT Confidence: ${(_iotConfidence! * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              Text(
                'Best Weather Condition: $bestWeatherCondition\nConfidence: ${(bestConfidence * 100).toStringAsFixed(2)}%',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    sexController.dispose();
    bpmController.dispose();
    fbsController.dispose();
    cholController.dispose();
    super.dispose();
  }
}
