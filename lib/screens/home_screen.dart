import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:weather_app/class_models/adress_model.dart';
import 'package:weather_app/api_service/api_service.dart';
import 'package:weather_app/api_service/apiservice_adress.dart';
import 'package:weather_app/class_models/weather_model.dart';
import 'package:weather_app/screens/details_screen.dart';
import 'package:weather_app/screens/select_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  Address? address;
  WeatherData? weatherData;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current address and weather data from API
  Address? address;
  WeatherData? weatherData;
  // Default coordinates set to San Francisco
  double latitude = 37.7749;
  double longitude = -122.4194;

  @override
  void initState() {
    super.initState();
    // First load saved coordinates then update weather and address info
    _loadLastCoordinates().then((_) {
      _fetchInitialWeather();
      _getAddress();
    });
  }

  /// Navigates to the DetailsScreen if weatherData is available.
  void _goToDetailsScreen() {
    if (weatherData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(weatherData: weatherData!),
      ),
    );
  }

  /// Loads last saved coordinates using SharedPreferences
  Future<void> _loadLastCoordinates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedLat = prefs.getDouble("lastLat");
    double? savedLng = prefs.getDouble("lastLng");
    if (savedLat != null && savedLng != null) {
      setState(() {
        latitude = savedLat;
        longitude = savedLng;
      });
      print("Last selected coordinates loaded: lat=$savedLat, lng=$savedLng");
    } else {
      print("No saved coordinates found, using default values.");
    }
  }

  /// Fetches the address for the current coordinates via API.
  void _getAddress() async {
    Address? fetchedAddress = await fetchAddress(latitude, longitude);
    setState(() {
      address = fetchedAddress;
    });
  }

  /// Fetches the initial weather data from the API.
  Future<void> _fetchInitialWeather() async {
    weatherData = await fetchWeatherData(latitude, longitude);
    if (mounted) {
      setState(() {});
    }
  }

  /// Navigates to the location selection screen and updates state with the selected location.
  Future<void> _getSelectedLocation() async {
    var result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => SelectLocationScreen()),
    );

    if (result != null) {
      LatLng newLocation = result['location'] as LatLng;
      Address? newAddress = result['address'] as Address?;
      print("Selected coordinates: lat=${newLocation.latitude}, lng=${newLocation.longitude}");
      if (newAddress != null) {
        print("Address received: ${newAddress.toString()}");
      }
      // Update state with new location and address.
      setState(() {
        latitude = newLocation.latitude;
        longitude = newLocation.longitude;
        address = newAddress;
      });

      // Update weather data based on the new coordinates.
      WeatherData? newWeatherData = await fetchWeatherData(latitude, longitude);
      setState(() {
        weatherData = newWeatherData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image fills the screen.
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // House image placed near the bottom center.
          Align(
            alignment: Alignment(0, 1.03),
            child: Image.asset(
              'lib/assets/images/house.png',
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Transparent AppBar for a minimal look.
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                ),
                Column(
                  children: [
                  SizedBox(height: screenWidth * 0.02),
                  FutureBuilder<Address?>(
                      future: fetchAddress(latitude, longitude),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              "Error loading address",
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(
                            child: Text(
                              "No address found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          final Address addr = snapshot.data!;
                          return Text(
                            "${addr.city}, ${addr.country}",
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: screenWidth * 0.070,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                 
                    SizedBox(height: screenHeight * 0.01),
                    // AnimatedSwitcher for temperature display:
                    // Displays a loader until weather data is available.
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: (weatherData == null)
                          ? Center(
                              key: ValueKey('loading-weather'),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              " ${weatherData?.current.temperature ?? 'Loading...'}°C",
                              key: ValueKey('weather-loaded'),
                              style: TextStyle(
                                fontSize: screenWidth * 0.070,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: 1),
                    // Column for weather icon and description with AnimatedSwitcher.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // AnimatedSwitcher for weather icon.
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: (weatherData?.current != null)
                              ? Image.asset(
                                  getWeatherDescriptionIcon(weatherData?.current.weatherCode),
                                  width: screenWidth * 0.2,
                                  height: screenWidth * 0.2,
                                  key: ValueKey('weatherIcon'),
                                )
                              : Container(
                                  key: ValueKey('loadingIcon'),
                                  width: screenWidth * 0.2,
                                  height: screenWidth * 0.2,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                        ),
                        // AnimatedSwitcher for weather description text.
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: (weatherData?.current != null)
                              ? Text(
                                  getWeatherDescription(weatherData?.current.weatherCode),
                                  key: ValueKey('weatherDescription'),
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: screenWidth * 0.070,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(
                                  key: ValueKey('loadingDescription'),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom left: Location selection button.
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: IconButton(
                onPressed: () {
                  print("Location selection button pressed");
                  _getSelectedLocation();
                },
                icon: ImageIcon(
                  AssetImage('lib/assets/images/location.png'),
                  size: screenWidth * 0.1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Bottom right: Button to navigate to the details screen.
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: IconButton(
                onPressed: () {
                  _goToDetailsScreen();
                  print("Details screen button pressed. Wind Direction: ${weatherData?.current.windDirection}");
                },
                icon: ImageIcon(
                  AssetImage("lib/assets/images/details.png"),
                  size: screenWidth * 0.1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getWeatherDescription(int? weatherCode) {
  if (weatherCode == null) return "Veri Yok";
  if (weatherCode == 0) {
    return "Clear sky";
  } else if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
    return "Partly cloudy";
  } else if (weatherCode == 45 || weatherCode == 48) {
    return "Fog and depositing rime fog";
  } else if (weatherCode == 51 || weatherCode == 53 || weatherCode == 55) {
    return "Drizzle: Light, moderate, and dense intensity";
  } else if (weatherCode == 56 || weatherCode == 57) {
    return "Freezing Drizzle: Light and dense intensity";
  } else if (weatherCode == 61 || weatherCode == 63 || weatherCode == 65) {
    return "Rain: Slight, moderate and heavy intensity";
  } else if (weatherCode == 66 || weatherCode == 67) {
    return "Freezing Rain: Light and heavy intensity";
  } else if (weatherCode == 71 || weatherCode == 73 || weatherCode == 75) {
    return "Snow fall: Slight, moderate, and heavy intensity";
  } else if (weatherCode == 77) {
    return "Snow grains";
  } else if (weatherCode == 80 || weatherCode == 81 || weatherCode == 82) {
    return "Rain showers: Slight, moderate, and violent";
  } else if (weatherCode == 85 || weatherCode == 86) {
    return "Snow showers: Slight and heavy";
  } else if (weatherCode == 95) {
    return "Thunderstorm: Slight or moderate";
  } else if (weatherCode == 96 || weatherCode == 99) {
    return "Thunderstorm with slight and heavy hail";
  } else {
    return "Hava Güncellendi!";
  }
}

String getWeatherDescriptionIcon(int? weatherCode) {
  if (weatherCode == null) return 'lib/assets/images/x.png';
  if (weatherCode == 0) {
    return ('lib/assets/images/clearsky.png');
  } else if (weatherCode == 1 || weatherCode == 2 || weatherCode == 3) {
    return ('lib/assets/images/partycloud.png');
  } else if (weatherCode == 45 || weatherCode == 48) {
    return ('lib/assets/images/fog.png');
  } else if (weatherCode == 51 || weatherCode == 53 || weatherCode == 55 ||
      weatherCode == 56 || weatherCode == 57) {
    return ('lib/assets/images/somerain.png');
  } else if (weatherCode == 61 || weatherCode == 63 || weatherCode == 65 ||
      weatherCode == 66 || weatherCode == 67) {
    return ('lib/assets/images/somerain.png');
  } else if (weatherCode == 71 || weatherCode == 73 || weatherCode == 75 ||
      weatherCode == 77 || weatherCode == 85 || weatherCode == 86) {
    return ('lib/assets/images/snow.png');
  } else if (weatherCode == 80 || weatherCode == 81 || weatherCode == 82) {
    return ('lib/assets/images/heavyrain.png');
  } else if (weatherCode == 95 || weatherCode == 96 || weatherCode == 99) {
    return ('lib/assets/images/thunderstorm.png');
  } else {
    return ('lib/assets/images/x.png');
  }
}
