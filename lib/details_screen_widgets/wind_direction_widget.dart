import 'package:flutter/material.dart';
import 'package:weather_app/class_models/weather_model.dart';

/// A widget that displays the wind direction information.
/// It shows a title, a compass image, and a descriptive text.
class WindDirectionWidget extends StatelessWidget {
  final WeatherData? weatherData;
  final double screenHeight;
  final double screenWidth;

  const WindDirectionWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Responsive width and height based on screen dimensions.
      width: screenWidth * 0.450,
      height: screenHeight * 0.27,
      decoration: BoxDecoration(
        // Semi-transparent deep purple background.
        color: Colors.deepPurple.withOpacity(0.2),
        // Deep purple border with a width of 2.
        border: Border.all(color: Colors.deepPurple, width: 2),
        // Rounded corners for the container.
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title text: "Wind Direction".
          Text(
            "Wind Direction",
            style: TextStyle(
              fontFamily: "fontweather",
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
          ),
          // Small vertical gap.
          SizedBox(height: screenHeight * 0.005),
          // Compass image indicating wind direction.
          Expanded(
            child: Image.asset(
              "lib/assets/images/compassico.png",
              width: screenWidth * 0.30,
              height: screenHeight * 0.15,
            ),
          ),
          // Descriptive text with dynamic wind direction value.
          Text(
            "Wind Direction ${weatherData?.current.windDirection} meters above ground",
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "fontweather",
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
