import 'dart:async';

import 'package:agriconnect/common/bottom_bar.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomBar(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                right: -25,
                top: -5,
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/bg1.png',
                    height: size.height * 0.15,
                    width: size.width * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height * 0.25,
                        ),
                        Image.asset(
                          'assets/images/app_logo.jpg',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/images/splash_logo.jpg',
                          height: 200,
                          width: 200,
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/images/logo.jpg',
                      height: 80,
                      width: 80,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
