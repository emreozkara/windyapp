import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/class_models/7days_model.dart';


Future<List<DailyWeather>> fetch7DayWeather(double latitude, double longitude) async {
  final String apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=Europe/Istanbul";
  
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final List<DailyWeather> forecast = [];

    for (int i = 0; i < jsonData['daily']['time'].length; i++) {
      forecast.add(DailyWeather.fromJson(jsonData['daily'], i));
    }

    return forecast;
  } else {
    throw Exception("Data not fetched from API!");
  }
}