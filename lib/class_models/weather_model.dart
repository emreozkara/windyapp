class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final CurrentWeather current;
  final DailyWeather daily;
  final HourlyWeather hourly;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.current,
    required this.daily,
    required this.hourly,
  });

 factory WeatherData.fromJson(Map<String, dynamic> json) {
  print("📌 WeatherData in JSON: $json");

  if (!json.containsKey('current') || json['current'] == null) {
    print("⚠ Warning: 'current' data not found in JSON!");
  }

  return WeatherData(
    latitude: json['latitude'] ?? 0.0,
    longitude: json['longitude'] ?? 0.0,
    timezone: json['timezone'] ?? '',
    timezoneAbbreviation: json['timezone_abbreviation'] ?? '',
    elevation: json['elevation'] ?? 0.0,
    current: json.containsKey('current') && json['current'] != null
        ? CurrentWeather.fromJson(json['current'])
        : CurrentWeather.fromJson({}),
    daily: json.containsKey('daily') && json['daily'] != null
        ? DailyWeather.fromJson(json['daily'])
        : DailyWeather.fromJson({}),
    hourly: json.containsKey('hourly') && json['hourly'] != null
        ? HourlyWeather.fromJson(json['hourly'])
        : HourlyWeather.fromJson({})
  );
}

  get hourlyWeather => null;
}

class CurrentWeather {
  final String time;
  final double temperature;
  final double rain;
  final int humidity;
  final int weatherCode;
  final String hourOnly;
  final double windSpeed;
  final int windDirection; 

  CurrentWeather({
    required this.time,
    required this.temperature,
    required this.rain,
    required this.humidity,
    required this.weatherCode,
    required this.hourOnly,
    required this.windSpeed,
    required this.windDirection, 
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    String rawTime = json['time'] ?? '';
    String extractedHour = '';

    if (rawTime.isNotEmpty) {
      try {
        DateTime parsedTime = DateTime.parse(rawTime);
        extractedHour = "${parsedTime.hour}:${parsedTime.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        print("⚠ Zaman formatı hatalı! Gelen veri: $rawTime");
      }
    }

    return CurrentWeather(
      windSpeed: json['wind_speed_10m'] ?? 0.0,
      windDirection: json['wind_direction_10m'] ?? 0, // 📌 API'den rüzgar yönü çekildi.
      time: rawTime,
      temperature: json['temperature_2m'] ?? 0.0,
      rain: json['precipitation_probability'] ?? 0.0,
      humidity: json['relative_humidity_2m'] ?? 0,
      weatherCode: json['weather_code'] ?? 0,
      hourOnly: extractedHour,
    );
  }
}


class DailyWeather {
  final List<String> time;
  final List<int> weatherCode;
  final List<double> uvIndexMax;
  final List<String> sunrise;
  final List<String> sunset;

  DailyWeather({
    required this.time,
    required this.weatherCode,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
  print("📌 Günlük hava durumu JSON: $json");

  return DailyWeather(
    time: json['time'] != null ? List<String>.from(json['time']) : [],
    weatherCode: json['weather_code'] != null ? List<int>.from(json['weather_code']) : [],
    uvIndexMax: json['uv_index_max'] != null ? List<double>.from(json['uv_index_max']) : [],
    sunrise: json.containsKey('sunrise') && json['sunrise'] != null
        ? List<String>.from(json['sunrise'])
        : ['data not found'],  
    sunset: json.containsKey('sunset') && json['sunset'] != null
        ? List<String>.from(json['sunset'])
        : ['data not found'],  
  );
}

}

class HourlyWeather {
  final List<int> rainProbability;
 
  HourlyWeather({ 
      required this.rainProbability,

  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      rainProbability: json['precipitation_probability'] != null ? List<int>.from(json['precipitation_probability']) : [],
     
    );
  }
}