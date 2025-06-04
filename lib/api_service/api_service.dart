import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/class_models/weather_model.dart';


Future<WeatherData?> fetchWeatherData(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=sunset,sunrise,uv_index_max&hourly=precipitation_probability&current=temperature_2m,relative_humidity_2m,weather_code,is_day,rain,wind_speed_10m,wind_direction_10m&timezone=auto&models=best_match'
  );

  try {
    final response = await http.get(url);

    if (response.body.isEmpty) {
      print("⚠ API response is empty! Data not fetched.");
      return null;
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    print("✅ API JSON Response: $jsonData");  
    print("📌 JSON Keys: ${jsonData.keys.toList()}"); 

   
    return WeatherData.fromJson(jsonData); 

  } catch (e) {
    print("⚠ Error occurred: $e");
    return null;
  }
}

