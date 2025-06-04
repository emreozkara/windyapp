class HourlyWeather2 {
  final String time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability; 

    HourlyWeather2({required this.time, required this.temperature, required this.weatherCode, required this.precipitationProbability});

  factory HourlyWeather2.fromJson(Map<String, dynamic> json, int index) {
    return HourlyWeather2(
      time: json['time'][index] ?? '',
      temperature: json['temperature_2m'][index]?.toDouble() ?? 0.0,
      weatherCode: json['weathercode'][index] ?? 0,
      precipitationProbability: json['precipitation_probability'][index] ?? 0,
    );
  }
}