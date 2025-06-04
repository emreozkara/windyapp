import 'package:flutter/material.dart';
import 'package:weather_app/screens/home_screen.dart';

void main() {
  runApp(MaterialApp(
    title: "Windy",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.blue,
      secondaryHeaderColor: Colors.blueAccent,
    ),
    home: HomeScreen(),
  ));
}






     
       
    