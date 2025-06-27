import 'dart:async';

import 'package:app_clima/utils/colors.dart';
import 'package:app_clima/view/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer(Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Discover The\nWeather In Your City",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: "JetBrainsMono",
                    letterSpacing: -.5,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              // Reemplaza el Spacer con el GIF de internet
            Expanded(child: 
            Image.asset("assets/weather.gif")
            ),
              Center(
                child: Text(
                  "Get to know your weather maps\nand radar precipitation forecast",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32 / 2,
                    fontFamily: "JetBrains",
                    fontWeight: FontWeight.normal,
                    letterSpacing: -.5,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 35),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorButton,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _timer.cancel();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 40,
                    ),
                    child: Text(
                      "Iniciar",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontFamily: "JetBrainsMono",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
