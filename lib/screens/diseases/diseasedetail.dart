import 'dart:io';

import 'package:flutter/material.dart';

class DiseasePage extends StatelessWidget {
  final Map<String, dynamic> disease;
  final File? predictedImage; // Optional image parameter

  DiseasePage({required this.disease, this.predictedImage});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(disease['Disease_Name'] ?? 'Disease Details'),
          bottom: const TabBar(
            labelColor: Colors.green,
            indicatorColor: Colors.green,
            tabs: [
              Tab(text: 'Description'),
              Tab(text: 'Treatment'),
              Tab(text: 'Images'),
            ],
          ),
        ),
        body: Column(
          children: [
            predictedImage != null // Check for null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      predictedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.network(
                    disease['relateddiseaseimg'] ?? '', // Fallback logic
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ), // Show error icon if image fails to load
                      );
                    },
                  ),
            Expanded(
              child: TabBarView(
                children: [
                  // First Tab: Description
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Description'] ??
                            'No description available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Causes:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Causes'] ?? 'No causes available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Symptoms:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Symptoms'] ?? 'No symptoms available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Affected Plant Parts:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Affected_Plant_Parts'] ??
                            'No affected parts available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Spread and Impact:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Spread_and_Impact'] ??
                            'No information available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Disease Severity Level and Value:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(disease['DISEASE_Severity_Level'] ?? 'N/A'),
                            Text(
                              (disease['DISEASE_Severity_Value'] != null)
                                  ? disease['DISEASE_Severity_Value'].toString()
                                  : 'N/A',
                            ),
                            const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Second Tab: Treatment
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Treatment:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(disease['Treatment'] ??
                            'No treatment information available.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Management Tips:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Management Tips: ${disease['MANAGEMENT_TIPS'] ?? 'No management tips available.'}',
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Prevention:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Prevention: ${disease['Prevention'] ?? 'No prevention tips available.'}',
                        ),
                      ],
                    ),
                  ),
                  // Third Tab: Images (Grid View)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: disease['Images'] != null &&
                            disease['Images'] is List &&
                            disease['Images'].isNotEmpty
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // Number of columns in the grid
                              childAspectRatio: 1, // Aspect ratio of the items
                              crossAxisSpacing: 8, // Space between columns
                              mainAxisSpacing: 8, // Space between rows
                            ),
                            itemCount: disease['Images'].length,
                            itemBuilder: (context, index) {
                              final img = disease['Images'][index];
                              return Card(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    img ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.error,
                                            color: Colors
                                                .red), // Error icon for each image
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text('No images available.'),
                          ),
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
