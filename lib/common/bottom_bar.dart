import 'package:agriconnect/screens/media/camerapage.dart';
import 'package:agriconnect/screens/media/gallery_screen.dart';
import 'package:agriconnect/screens/homescreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;

  List<Widget> pages = [const HomePage(),  GalleryPage()];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: FloatingActionButton(
          onPressed: () async {
            try {
              final cameras = await availableCameras();
              if (cameras.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraPage(cameras: cameras),
                  ),
                );
              } else {
                // Handle if no cameras are available
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No cameras available')),
                );
              }
            } catch (e) {
              // Handle any error that occurs while fetching the cameras
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load cameras: $e')),
              );
            }
          },
          backgroundColor: Colors.green,
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: updatePage,
        currentIndex: _page,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black26,
        iconSize: 28,
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 0 ? Colors.green : Colors.transparent,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(Icons.home_filled),
            ),
          ),
          BottomNavigationBarItem(
            label: 'Gallery',
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 1 ? Colors.green : Colors.transparent,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(Icons.collections),
            ),
          ),
        ],
      ),
    );
  }
}
