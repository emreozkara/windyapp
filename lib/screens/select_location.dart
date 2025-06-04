import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/class_models/adress_model.dart'; // Address model definition
import 'package:weather_app/api_service/api_service.dart'; // Functions: fetchAddress, fetchWeatherData
import 'package:weather_app/api_service/apiservice_adress.dart';
import 'package:weather_app/secrets.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  // Controller to interact with the Google Map
  GoogleMapController? mapController;
  // Default selected location (San Francisco coordinates)
  LatLng selectedLocation = LatLng(37.7749, -122.4194);
  // Instance for GooglePlace API
  late GooglePlace googlePlace;
  // Set of markers displayed on the map
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize GooglePlace with the secret API key
    googlePlace = GooglePlace(Secrets.googleApiKey);
  }

  /// Loads the last selected location from SharedPreferences
  Future<void> _loadLastSelectedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble("lastLat");
    double? lng = prefs.getDouble("lastLng");

    if (lat != null && lng != null) {
      setState(() {
        // Set the previously saved location
        selectedLocation = LatLng(lat, lng);
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId("selected_location"),
            position: selectedLocation,
          ),
        );
      });
      print("📌 Last selected location loaded: lat=$lat, lng=$lng");

      // If the map controller is available, animate camera to the saved location
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: selectedLocation, zoom: 14),
          ),
        );
      }
    }
  }

  /// Saves the currently selected location to SharedPreferences
  Future<void> _saveLastSelectedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("lastLat", selectedLocation.latitude);
    await prefs.setDouble("lastLng", selectedLocation.longitude);
  }

  /// Callback triggered when the map is created
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
    _loadLastSelectedLocation();
  }

  /// Callback triggered when the user taps on the map.
  /// Updates the selected location and marker, then animates the camera.
  void _onMapTapped(LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selected_location"),
          position: selectedLocation,
        ),
      );
    });
    _saveLastSelectedLocation();

    // Animate the camera to the new selected location
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLocation, zoom: 14),
      ),
    );
    print("📌 Map tapped, selected location: lat=${latLng.latitude}, lng=${latLng.longitude}");
  }

  /// Function called when the user confirms the selected location.
  /// It fetches the address for the coordinates, saves the location,
  /// shows a snackbar, and finally returns the selected location and address.
  void _selectLocation() async {
    if (!mounted) return;
  
    print("📌 _selectLocation called. Selected location: lat=${selectedLocation.latitude}, lng=${selectedLocation.longitude}");
  
    setState(() {
      // Update marker position for the selected location
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selected_location"),
          position: selectedLocation,
        ),
      );
    });
  
    _saveLastSelectedLocation();

    // Fetch the address corresponding to the selected location via API
    Address? address =
        await fetchAddress(selectedLocation.latitude, selectedLocation.longitude);
    if (address != null) {
      print("📌 Address fetched from API: ${address.toString()}");
    } else {
      print("⚠ Failed to fetch address from API.");
    }

    // Return the selected location and address to the previous screen
    Navigator.pop<Map<String, dynamic>>(context, {
      'location': selectedLocation,
      'address': address,
    });
  
    // Animate the camera to the selected location
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLocation, zoom: 14),
      ),
    );
  
    // Example call: Fetch weather data and print the temperature
    fetchWeatherData(selectedLocation.latitude, selectedLocation.longitude).then((data) {
      print("📌 Temperature from API: ${data?.current.temperature}°C");
    });
  
    
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // Stack used to overlay the Google Map, search bar, and buttons
      body: Stack(
        children: [
          // GoogleMap fills the screen
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: selectedLocation, zoom: 12),
              markers: markers,
              onTap: _onMapTapped,
            ),
          ),
          // Positioned search bar at the top
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Autocomplete<String>(
              // Options builder calls GooglePlace's autocomplete API
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return [];
                }
                try {
                  var result = await googlePlace.autocomplete.get(textEditingValue.text);
                  if (result?.predictions != null) {
                    return result?.predictions
                            ?.map((p) => p.description ?? "")
                            .toList() ??
                        [];
                  } else {
                    return [];
                  }
                } catch (e) {
                  print("Google Place API error: $e");
                  return [];
                }
              },
              // Builds the search field widget
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onFieldSubmitted) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)
                    ],
                  ),
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        hintText: "Search city...", border: InputBorder.none),
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                );
              },
              // When a search option is selected, update the map marker and location
              onSelected: (String selectedPlace) async {
                try {
                  var result = await googlePlace.autocomplete.get(selectedPlace);
                  if (result?.predictions?.isNotEmpty ?? false) {
                    var placeId = result!.predictions!.first.placeId;
                    if (placeId != null) {
                      var details = await googlePlace.details.get(placeId);
                      var lat = details?.result?.geometry?.location?.lat;
                      var lng = details?.result?.geometry?.location?.lng;
                      if (lat != null && lng != null) {
                        setState(() {
                          selectedLocation = LatLng(lat, lng);
                          markers.clear();
                          markers.add(
                            Marker(
                              markerId: MarkerId("selected_location"),
                              position: selectedLocation,
                            ),
                          );
                        });
                        _saveLastSelectedLocation();
                        mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                              CameraPosition(target: selectedLocation, zoom: 14)),
                        );
                        print("📌 Location selected via search: lat=$lat, lng=$lng");
                      }
                    }
                  }
                } catch (e) {
                  print("Error occurred: $e");
                }
              },
            ),
          ),
          // Bottom left: Back button and location selection button
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black)),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      print("📌 Save location button pressed");
                      _selectLocation();
                    },
                    backgroundColor: Colors.deepPurpleAccent,
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
