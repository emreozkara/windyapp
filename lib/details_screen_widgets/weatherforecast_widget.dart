import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/accordion_section.dart';
import 'package:weather_app/class_models/7days_model.dart';
import 'package:weather_app/class_models/7days_temp.dart';
import 'package:weather_app/api_service/api_service7days.dart';
import 'package:weather_app/api_service/api_service7days_temp.dart';
import 'package:weather_app/class_models/weather_model.dart' hide DailyWeather;
import 'package:weather_app/screens/home_screen.dart';

class WeatherForecastWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final WeatherData? weatherData;

  const WeatherForecastWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.weatherData,
  });

  @override
  _WeatherForecastWidgetState createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  List<bool> isAccordionOpenList = [];
  List<DailyWeather> forecastData = [];
  List<HourlyWeather2> hourlyWeatherList = [];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  /// Fetches the 7-day forecast from API and initializes the accordion open state.
  Future<void> fetchWeather() async {
    List<DailyWeather> data =
        await fetch7DayWeather(widget.latitude, widget.longitude);
    setState(() {
      forecastData = data;
      isAccordionOpenList = List.generate(data.length, (index) => false);
    });
  }

  /// Fetches hourly weather data for the selected day, filters it,
  /// and then shows it in a modal bottom sheet as an Accordion.
  void _showHourlyAccordion(DailyWeather item, double screenWidth, double screenHeight) async {
    // Fetch hourly weather data from the API.
    hourlyWeatherList = await fetchHourlyWeather(widget.latitude, widget.longitude);

    // Filter the hourly data for the selected day (e.g., "2025-05-26").
    hourlyWeatherList = hourlyWeatherList.where((hourly) {
      return hourly.time.startsWith(item.date);
    }).toList();

    // Display the hourly data in a modal bottom sheet with an Accordion.
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent,
            
            border: Border.all(color: Colors.deepPurple, width: 3),
          ),
          child: Accordion(
            maxOpenSections: 1,
            headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            children: [
              AccordionSection(
                header: Center(
                  child: Text(
                    "Hourly Data",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontFamily: 'fontweather',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Set a fixed height to enable scrolling.
                  height: screenHeight * 0.4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: hourlyWeatherList.length,
                    itemBuilder: (context, index) {
                      // Parse the time string into a DateTime object and format it.
                      DateTime dt = DateTime.parse(hourlyWeatherList[index].time);
                      String formattedTime =
                          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                      return ListTile(
                        dense: true,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "🕒 $formattedTime",
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              " 🌡️ ${hourlyWeatherList[index].temperature}°C",
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "🌧 ${hourlyWeatherList[index].precipitationProbability}%",
                              style: TextStyle(
                                fontSize: screenWidth * 0.040,
                                color: Colors.black,
                              ),
                            ),
                            Image.asset(
                              getWeatherDescriptionIcon(hourlyWeatherList[index].weatherCode),
                              width: screenWidth * 0.08,
                              height: screenHeight * 0.08,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions for responsive layout.
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.94,
      height: screenHeight * 0.33,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: forecastData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: screenWidth * 0.90,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: forecastData.length,
                itemBuilder: (context, index) {
                  final item = forecastData[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: screenWidth * 0.90,
                      height: screenHeight * 0.09,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        
                        border: Border.all(color: Colors.deepPurple, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Day name button: tapping it shows hourly data.
                          TextButton(
                            onPressed: () {
                              _showHourlyAccordion(item, screenWidth, screenHeight);
                            },
                            child: Text(
                              "${item.dayName}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                          // Row displaying weather icon and temperatures.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                getWeatherDescriptionIcon(item.weatherCode),
                                width: screenWidth * 0.10,
                                height: screenHeight * 0.05,
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Text(
                                "🌡 ${item.maxTemp}°C / ${item.minTemp}°C",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Text(
                                "🌧 ${item.rainChance}%",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.040,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
