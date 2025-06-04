import 'package:flutter/material.dart';
import 'package:weather_app/class_models/weather_model.dart';
import 'package:weather_app/details_screen_widgets/detailrow_widget.dart';
import 'package:weather_app/details_screen_widgets/uv_indexwidget.dart';
import 'package:weather_app/details_screen_widgets/weatherforecast_widget.dart';
import 'package:weather_app/details_screen_widgets/wind_direction_widget.dart';

class DetailsScreen extends StatefulWidget {
  final WeatherData? weatherData;

  const DetailsScreen({Key? key, this.weatherData}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  /// Formats the provided dateTime string into a "hour:minute" format.
  /// In case of an error during parsing, prints an error message and returns a fallback text.
  String formatTime(String dateTime) {
    try {
      final DateTime parsedTime = DateTime.parse(dateTime);
      return "${parsedTime.hour}:${parsedTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      
      return "Invalid Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
       
          Positioned.fill(
            child: Image.asset(
              "lib/assets/images/background2.png",
              fit: BoxFit.cover,
            ),
          ),
     
          Positioned(
            top: screenHeight * 0.130,
            right: screenWidth * 0.0400,
            child: UVIndexWidget(
              uvValue: widget.weatherData?.daily.uvIndexMax.isNotEmpty == true
                  ? widget.weatherData!.daily.uvIndexMax[0].toInt()
                  : 0,
            ),
          ),
          
          Positioned(
            top: screenHeight * 0.130,
            left: screenWidth * 0.0280,
            child: WindDirectionWidget(
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              weatherData: widget.weatherData,
            ),
          ),
          // Hava Durumu Tahmin Kutusu (Ortada)
          Align(
            alignment: const Alignment(-0.3, 0.240),
            child: WeatherForecastWidget(
              latitude: widget.weatherData?.latitude ?? 0.0,
              longitude: widget.weatherData?.longitude ?? 0.0,
              weatherData: widget.weatherData,
            ),
          ),
        
          Positioned(
            bottom: screenHeight * 0.0170,
            right: screenWidth * -0.2,
            child: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                children: [
                  DetailRowWidget2(
                    imagePath: "lib/assets/images/sunrise_icon.png",
                    detail:
                        'Sunrise: ${formatTime(widget.weatherData?.daily.sunrise.isNotEmpty == true ? widget.weatherData!.daily.sunrise[0] : 'Veri Yok')}',
                  ),
                  SizedBox(height: screenHeight * 0.00005),
                  DetailRowWidget2(
                    imagePath: "lib/assets/images/sunset_ico.png",
                    detail:
                        'Sunset: ${formatTime(widget.weatherData?.daily.sunset.isNotEmpty == true ? widget.weatherData!.daily.sunset[0] : 'Veri Yok')}',
                  ),
                ],
              ),
            ),
          ),
      
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: Align(
                  alignment: const Alignment(-0.3, 0.0),
                  child: Text(
                    "W İ N D Y",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      fontSize: screenWidth * 0.07,
                      fontFamily: "fontweather",
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  children: [
                    DetailRowWidget(
                      imagePath: "lib/assets/images/windspeed_ico.png",
                      detail: 'Windspeed',
                      value: ' ${widget.weatherData?.current.windSpeed} km/h',
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    DetailRowWidget(
                      imagePath: "lib/assets/images/feelslike_ico.png",
                      detail: 'Feels Like',
                      value: '${widget.weatherData?.current.temperature}°C',
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    DetailRowWidget(
                      imagePath: "lib/assets/images/humidity_ico.png",
                      detail: 'Humidity',
                      value: '%${widget.weatherData?.current.humidity}',
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    DetailRowWidget(
                      imagePath: "lib/assets/images/rainforce_ico.png",
                      detail: 'Precipitation',
                      value: '%${widget.weatherData?.hourly.rainProbability.isNotEmpty == true ? widget.weatherData!.hourly.rainProbability[0] : 'Veri Yok'}',
                    ),
                    SizedBox(height: screenHeight * 0.020),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
