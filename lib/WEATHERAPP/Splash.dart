import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:untitled1/WEATHERAPP/Weather%20app.dart';

class splashScreen extends StatefulWidget {
  splashScreen({Key? key}) : super(key: key);

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(microseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the animation
    _controller.forward();

    // Navigate to home page after 6 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WeatherAppss()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(
          context,
          Center(
            child: FadeTransition(
              opacity: _animation,
              child: Image.asset(
                "assets/weathersplash.gif",
                height: ResponsiveValue<double>(
                  context,
                  defaultValue: 350.0,
                  valueWhen: const [
                    Condition.smallerThan(name: MOBILE, value: 300.0),
                    Condition.largerThan(name: TABLET, value: 400.0),
                  ],
                ).value,
                width: ResponsiveValue<double>(
                  context,
                  defaultValue: 350.0,
                  valueWhen: const [
                    Condition.smallerThan(name: MOBILE, value: 300.0),
                    Condition.largerThan(name: TABLET, value: 400.0),
                  ],
                ).value,
                //color: Colors.white,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ),
        maxWidth: 1200,
        minWidth: 480,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.resize(480, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
          ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          ResponsiveBreakpoint.resize(1200, name: DESKTOP),
        ],
      ),
    );
  }
}
