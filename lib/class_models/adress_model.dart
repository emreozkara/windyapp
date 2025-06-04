class Address {
  final String city;
  final String country;

  Address({
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    String city = json['city'] ?? json['town'] ?? json['village'] ?? json['state'] ?? 'Unknown';  
    String country = json['country'];
    return Address(city: city, country: country);
  }
  @override
  String toString() {
    String result = city;
  
    if (country != 'Unknown') {
      result += ', $country';
    }
    return result;
  }
}
