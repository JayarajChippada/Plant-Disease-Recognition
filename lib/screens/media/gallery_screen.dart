import 'package:agriconnect/screens/diseases/diseasedetail.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart'; // For loading assets
import 'package:flutter_tflite/flutter_tflite.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _images;
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
    _loadModel();
    loadJsonData(); // Load disease data on initialization
  }

  @override
  void dispose() {
    if (_modelLoaded) {
      Tflite.close();
    }
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

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      setState(() {
        _images = selectedImages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
              "Gallery",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: (_loading || !_modelLoaded) ? null : _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Pick Images from Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ),
            ),
            const SizedBox(height: 20),
            _images != null
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: _images!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          if (!_loading && _modelLoaded) {
                            await _predictImage(File(_images![index].path));
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              File(_images![index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Text(
                    'No images selected',
                    style: TextStyle(fontSize: 16.0),
                  ),
            const SizedBox(height: 20),
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
                            child: const Text('View Disease Details', style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
