import 'package:flutter/material.dart';
import 'package:my_tasks/features/home/splash_page/widgets/splash_body.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SplashBody(),

    );
  }
}
