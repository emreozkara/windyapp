import 'package:flutter/material.dart';

/// A widget that displays the UV index, its numeric value, a description, and a gradient indicator.
/// The indicator's position along the gradient represents the UV value.
class UVIndexWidget extends StatelessWidget {
  final int uvValue;

  /// Constructs a UVIndexWidget with the given [uvValue].
  /// The [uvValue] is expected to be in the range of 0 to 11.
  const UVIndexWidget({super.key, required this.uvValue});

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions for responsive layout.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the indicator's horizontal position based on the uvValue.
    // The multiplier of 170 represents the effective width of the gradient bar.
    double indicatorPosition = (uvValue / 11) * 170;
    // Clamp the position to ensure it stays within the 0 to 170 range.
    indicatorPosition = indicatorPosition.clamp(0, 170).toDouble();

    return Container(
      width: screenWidth * 0.450,
      height: screenHeight * 0.27,
      decoration: BoxDecoration(
        // A semi-transparent purple background.
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        // A deep purple border outlines the container.
        border: Border.all(color: Colors.deepPurple, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Display the title "UV Index".
          Text(
            "UV Index",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w300,
              fontFamily: "fontweather",
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Display the current UV value.
          Text(
            uvValue.toString(),
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
          ),
          const SizedBox(height: 8),
          // Display the UV description ("Low", "Moderate", etc.)
          Text(
            getUVDescription(uvValue),
            style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // A Stack widget to overlay the indicator on the gradient bar.
          Stack(
            children: [
              // The gradient bar representing the UV scale.
              Container(
                width: screenWidth * 0.420,
                height: screenHeight * 0.0120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // The indicator (a white circle with a black border) positioned on the gradient.
              Positioned(
                left: indicatorPosition,
                top: screenHeight * -0.015,
                child: Container(
                  width: screenWidth * 0.04,
                  height: screenHeight * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a human-readable description for the given UV value.
  /// - 0-2: Low  
  /// - 3-5: Moderate  
  /// - 6-7: High  
  /// - 8-10: Very High  
  /// - 11+: Extreme
  String getUVDescription(int uv) {
    if (uv <= 2) return "Low";
    if (uv <= 5) return "Moderate";
    if (uv <= 7) return "High";
    if (uv <= 10) return "Very High";
    return "Extreme";
  }
}
