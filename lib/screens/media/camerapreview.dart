import 'dart:convert';
import 'package:agriconnect/screens/diseases/diseasedetail.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart'; // Import flutter_tflite

class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _loading = false;
  String _predictionResult = '';
  bool _modelLoaded = false;
  List<dynamic> diseases = [];

  // New state variables for the predicted disease
  String? _predictedLabel;
  File? _predictedImage;

  @override
  void initState() {
    super.initState();
    // Load the model when the screen is initialized
    _loadModel();
    loadJsonData(); // Load JSON data in initState
  }

  @override
  void dispose() {
    // Close the interpreter when the screen is disposed
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: 'assets/models/model_unquant.tflite',
        labels: 'assets/models/labels.txt',
        numThreads: 1,
      );

      setState(() {
        _modelLoaded = res != null;
      });
    } catch (e) {
      setState(() {
        _modelLoaded = false;
      });
    }
  }

  Future<void> loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/disease/disease.json');
    final data = await json.decode(response);
    setState(() {
      diseases = data;
    });
  }

  Future<void> _predictImage(File image) async {
    if (_loading || !_modelLoaded) {
      return;
    }

    setState(() {
      _loading = true;
      _predictionResult = 'Processing...'; // Show a loading message
    });

    try {
      var recognitions = await Tflite.runModelOnImage(
        path: image.path, // Directly pass the image path here
        numResults: 2, // Set the number of results you want
        threshold: 0.2, // Confidence threshold
        imageMean: 0, // Mean normalization (depends on the model)
        imageStd:
            255, // Standard deviation normalization (depends on the model)
        asynch: true, // Run the model asynchronously
      );

      setState(() {
        _loading = false;
        if (recognitions != null && recognitions.isNotEmpty) {
          String predictedLabel = recognitions[0]['label'];
          predictedLabel = predictedLabel.split(' ')[1]; // Remove the number

          _predictionResult = recognitions.map((res) {
            return "$predictedLabel:  ${res['confidence'].toStringAsFixed(2)}";
          }).join("\n");

          // Store the predicted label and image
          _predictedLabel = predictedLabel;
          _predictedImage = image;
        } else {
          _predictionResult = 'No result found!';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _predictionResult = 'Error occurred during prediction';
      });
    }
  }

  void _navigateToDiseaseDetails() {
    // Find the disease in the loaded JSON data
    var matchedDisease = diseases.firstWhere(
      (disease) =>
          disease['Disease_Title'] == _predictedLabel ||
          disease['Disease_Name'] == _predictedLabel,
      orElse: () => null,
    );

    if (matchedDisease != null && _predictedImage != null) {
      // Navigate to DiseasePage if a match is found
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiseasePage(
            disease: matchedDisease,
            predictedImage: _predictedImage!, // Pass the predicted image
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Image.asset(
                'assets/images/logo.jpg',
                height: 70,
                width: 60,
                fit: BoxFit.fitHeight,
              ),
            ),
            const Text(
              "Preview Image",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    File(widget.picture.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.picture.name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 30),
            if (_predictionResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: _loading
                    ? const CircularProgressIndicator() // Show a loading indicator
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _predictionResult,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _predictedLabel != null &&
                                    _predictedImage != null
                                ? _navigateToDiseaseDetails
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              'View Disease Details',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retake'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // First, predict the disease
                    await _predictImage(File(widget.picture.path));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
