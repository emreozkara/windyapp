import 'package:intl/intl.dart';

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int rainChance;
  final String dayName; 
  final int weatherCode;

  DailyWeather({required this.date, required this.maxTemp, required this.minTemp, required this.rainChance, required this.dayName, required this.weatherCode});

  factory DailyWeather.fromJson(Map<String, dynamic> json, int index) {
    String rawDate = json['time'][index] ?? '';
    String dayName = '';

    if (rawDate.isNotEmpty) {
      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        dayName = DateFormat('EEEE', 'en_US').format(parsedDate); 
      } catch (e) {
        print("date format error $rawDate");
      }
    }

    return DailyWeather(
      date: rawDate,
      dayName: dayName, 
      maxTemp: json['temperature_2m_max'][index]?.toDouble() ?? 0.0,
      minTemp: json['temperature_2m_min'][index]?.toDouble() ?? 0.0,
      rainChance: json['precipitation_probability_max'][index] ?? 0,
      weatherCode: json['weather_code'][index] ?? 0,
    );
  }
}