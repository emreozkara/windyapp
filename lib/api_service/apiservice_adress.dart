import 'dart:convert';
import 'package:weather_app/class_models/adress_model.dart';
import 'package:http/http.dart' as http;
Future<Address?> fetchAddress(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'
  );

  try {
    final response = await http.get(url, headers: {
      'User-Agent': 'WeatherApp/1.0 (your_email@example.com)', 
    });

    if (response.body.isEmpty) {
      print("⚠ Response is empty (body is empty)");
      return null;
    }
    
    final Map<String, dynamic> data = jsonDecode(response.body);
    
    if (data['address'] == null) {
      print("⚠ 'address' field not found.");
      return null;
    }
    
    final Map<String, dynamic> addressData = data['address'];
    return Address.fromJson(addressData);
  } catch (e) {
    print('Reverse geocoding error: $e');
    return null;
  }
}