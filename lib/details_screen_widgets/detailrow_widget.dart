import 'package:flutter/material.dart';

/// DetailRowWidget displays a bottom‐left box with an image,
/// a centered detail text, and a right-aligned value.
class DetailRowWidget extends StatelessWidget {
  final String imagePath;
  final String detail;
  final String value;

  const DetailRowWidget({
    super.key,
    required this.imagePath,
    required this.detail,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        width: screenWidth * 0.480,
        height: screenHeight * 0.0530,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          border: Border.all(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Left: icon image.
              Image.asset(
                imagePath,
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
                color: Colors.white,
                fit: BoxFit.cover,
              ),
              // Center: detail text.
              Expanded(
                child: Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontFamily: 'fontweather',
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
              // Right: value.
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.0350,
                  fontFamily: 'fontweather',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DetailRowWidget2 displays a bottom‐right box with an image and detail text.
/// The image is on the left and the detail text is arranged in a column.
class DetailRowWidget2 extends StatelessWidget {
  final String detail;
  final String imagePath;

  const DetailRowWidget2({
    super.key,
    required this.imagePath,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4),
      child: Container(
        width: screenWidth * 0.470,
        height: screenHeight * 0.112,
        decoration: BoxDecoration(
          color: Colors.purpleAccent.withOpacity(0.2),
          border: Border.all(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [ 
            // Image with right-side padding.
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset(
                imagePath,
                width: screenWidth * 0.140,
                height: screenWidth * 0.140,
                fit: BoxFit.contain,
              ),
            ),
            // Detail text aligned in a column.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontFamily: 'fontweather',
                      fontSize: screenWidth * 0.0450,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
