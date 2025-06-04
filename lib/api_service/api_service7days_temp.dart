import 'package:weather_app/class_models/7days_temp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<HourlyWeather2>> fetchHourlyWeather(double latitude, double longitude) async {
  final String apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weathercode,precipitation_probability&timezone=Europe/Istanbul";

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final List<HourlyWeather2> hourlyForecast = [];

    for (int i = 0; i < jsonData['hourly']['time'].length; i ++) {
      hourlyForecast.add(HourlyWeather2.fromJson(jsonData['hourly'], i));
    }

    return hourlyForecast;
  } else {
    throw Exception("Hourly weather data not fetched from API!");
  }
}
