import 'package:agriconnect/screens/diseases/diseasedetail.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart' show rootBundle;

class HomePage extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> diseases = [];
  bool _isLoading = true; // Track the loading state

  @override
  void initState() {
    super.initState();
    // Load the JSON data when the widget is initialized
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    final String response =
        await rootBundle.loadString('assets/disease/disease.json');
    // Decode the JSON string into a list
    final data = await json.decode(response);
    setState(() {
      diseases = data; // Assign the decoded data to the diseases list
      _isLoading = false; // Update loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
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
                    "AgriConnect",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black, // Set text color to black
                    ),
                  ),
                ],
              ),
            ),
            pinned: true, // Keeps the app bar visible when scrolling
            expandedHeight: 200.0, // Height of the SliverAppBar when expanded
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Align to the bottom
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(
                      'assets/images/banner2.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Disease Collection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0), // Padding for the title
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Center loading indicator
                  : GridView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                      shrinkWrap:
                          true, // Allow GridView to take only the needed space
                      itemCount: diseases.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of items per row
                        childAspectRatio: 2 / 2.5, // Aspect ratio of the card
                        crossAxisSpacing:
                            10, // Spacing between cards horizontally
                        mainAxisSpacing: 10, // Spacing between cards vertically
                      ),
                      itemBuilder: (context, index) {
                        final disease = diseases[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to DiseasePage on tap
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiseasePage(disease: disease),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: Column(
                              children: [
                                // Disease image with loading indicator
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          disease['relateddiseaseimg'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          // Placeholder and error builder
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child; // Return child when loading is complete
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.error,
                                                  color: Colors
                                                      .red), // Show error icon instead of an image
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Disease name
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    disease['Disease_Name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
