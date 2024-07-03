import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class WeatherAppss extends StatefulWidget {
  @override
  _WeatherAppssState createState() => _WeatherAppssState();
}

class _WeatherAppssState extends State<WeatherAppss> {
  LocationData? _currentLocation;
  String _cityName = '';
  String _latitude = '';
  String _longitude = '';
  WeatherData _currentLocationWeather = WeatherData.empty();
  WeatherData _cityWeather = WeatherData.empty();
  WeatherData _latLongWeather = WeatherData.empty();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    _currentLocation = await location.getLocation();
    await _getWeatherByCoords(_currentLocation!.latitude!, _currentLocation!.longitude!, 'currentLocation');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getWeatherByCoords(double lat, double lon, String source) async {
    final apiKey = 'd8a09f73ac82e78c6398b4cba83373c8';
    String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(jsonDecode(response.body));
      setState(() {
        if (source == 'currentLocation') {
          _currentLocationWeather = weatherData;
        } else if (source == 'latLong') {
          _latLongWeather = weatherData;
        }
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> _getWeatherByCity(String cityName) async {
    final apiKey = 'd8a09f73ac82e78c6398b4cba83373c8';
    String url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(jsonDecode(response.body));
      setState(() {
        _cityWeather = weatherData;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<void> _getWeatherByLatLong() async {
    double lat = double.tryParse(_latitude) ?? 0.0;
    double lon = double.tryParse(_longitude) ?? 0.0;

    final apiKey = 'd8a09f73ac82e78c6398b4cba83373c8';
    String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(jsonDecode(response.body));
      setState(() {
        _latLongWeather = weatherData;
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Weather App',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title:  TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: 14),
                  tabs: [
                    Tab(
                      text: "Current",
                    ),
                    Tab(
                      text: "City",
                    ),
                    Tab(
                      text: "LatLong",
                    ),
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            children: [
              _buildCurrentLocationTab(),
              _buildCitySearchTab(),
              _buildLatLongTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationTab() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Weather',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildWeatherCard(
              city: _currentLocationWeather.cityName,
              temperature: _currentLocationWeather.temperature,
              description: _currentLocationWeather.description,
              humidity: _currentLocationWeather.humidity,
              windSpeed: _currentLocationWeather.windSpeed,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _getCurrentLocation();
              },
              child: Container(
                height: 48.0,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 15),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Refresh",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitySearchTab() {
    bool showWeatherCard = _cityWeather.cityName.isNotEmpty;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'City Weather',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelText: 'Enter City Name',
              ),
              onChanged: (value) {
                _cityName = value;
              },
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _getWeatherByCity(_cityName);
              },
              child: Container(
                height: 48.0,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 15),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Get Weather",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (showWeatherCard)
            _buildWeatherCard(
              city: _cityWeather.cityName,
              temperature: _cityWeather.temperature,
              description: _cityWeather.description,
              humidity: _cityWeather.humidity,
              windSpeed: _cityWeather.windSpeed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatLongTab() {
    //bool showWeatherCard = _latLongWeather.cityName.isNotEmpty;
    bool latitudeEntered = _latitude.isNotEmpty;
    bool longitudeEntered = _longitude.isNotEmpty;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Weather by Latitude/Longitude',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelText: 'Enter Latitude',
              ),
              onChanged: (value) {
                _latitude = value;
              },
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                labelText: 'Enter Longitude',
              ),
              onChanged: (value) {
                _longitude = value;
              },
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (_latitude.isNotEmpty && _longitude.isNotEmpty) {
                  _getWeatherByLatLong();
                }
              },
              child: Container(
                height: 48.0,
                width: 170,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 15),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Get Weather",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if ( latitudeEntered && longitudeEntered)
            _buildWeatherCard(
              city: _latLongWeather.cityName,
              temperature: _latLongWeather.temperature,
              description: _latLongWeather.description,
              humidity: _latLongWeather.humidity,
              windSpeed: _latLongWeather.windSpeed,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherCard({
    required String city,
    required double temperature,
    required String description,
    required int humidity,
    required double windSpeed,
  }) {
    return Card(
      color: Colors.orangeAccent.shade100,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                city,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildWeatherDetail('Temperature', '${temperature.toStringAsFixed(1)}°C'),
                  SizedBox(width: 27,),
                  _buildWeatherDetail('Description', description),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWeatherDetail('Humidity', '$humidity%'),
                  SizedBox(width: 107,),
                  _buildWeatherDetail('Wind', '${windSpeed.toStringAsFixed(1)} m/s'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWeatherDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 20, color: Colors.black87),
        ),
      ],
    );
  }
}



class WeatherData {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      cityName: json['name'],
    );
  }

  static WeatherData empty() {
    return WeatherData(
      temperature: 0.0,
      description: '',
      humidity: 0,
      windSpeed: 0.0,
      cityName: '',
    );
  }
}
