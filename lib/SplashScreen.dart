import 'package:career_guidance/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'Screens/navigation_screen.dart';
import 'Screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen())
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Displays Appname
            Text("CareerWise",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            CircularProgressIndicator(color: Colors.white,),

          ],
        ),
      ),
    );
  }
}
