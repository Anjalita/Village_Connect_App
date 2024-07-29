import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketUpdatesScreen extends StatefulWidget {
  @override
  _MarketUpdatesScreenState createState() => _MarketUpdatesScreenState();
}

class _MarketUpdatesScreenState extends State<MarketUpdatesScreen> {
  List<dynamic> locations = [];
  List<dynamic> crops = [];
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final response =
        await http.get(Uri.parse('http://192.168.5.1:3000/locations'));
    if (response.statusCode == 200) {
      setState(() {
        locations = json.decode(response.body);
      });
    } else {
      // Handle errors
      throw Exception('Failed to load locations');
    }
  }

  Future<void> _fetchCrops(String placeId) async {
    final response = await http
        .get(Uri.parse('http://192.168.5.1:3000/crops?place_id=$placeId'));
    if (response.statusCode == 200) {
      setState(() {
        crops = json.decode(response.body);
      });
    } else if (response.statusCode == 404) {
      // Handle no crops available
      setState(() {
        crops = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database not updated')),
      );
    } else {
      // Handle other errors
      throw Exception('Failed to load crops');
    }
  }

  void _onLocationChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedLocation = value;
        _fetchCrops(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Updates'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/user.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent Overlay
          Container(
            color: const Color.fromARGB(255, 255, 254, 254)
                .withOpacity(0.5), // Adjust opacity here
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        width: 2.0),
                    color: Colors.white.withOpacity(0.7),
                  ),
                  child: DropdownButton<String>(
                    hint: Text('Select Location'),
                    value: selectedLocation,
                    onChanged: _onLocationChanged,
                    underline: SizedBox(), // Hides the default underline
                    isExpanded: true,
                    items: locations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location['id'].toString(),
                        child: Text(
                          location['place_name'],
                          style: TextStyle(color: Colors.teal),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (selectedLocation != null) ...[
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        final cropName = crop['crop_name'];
                        final cropPrice = crop['price'];
                        final avgPriceString =
                            crop['avg_price']; // Average price as a string
                        final avgPrice = double.tryParse(avgPriceString) ??
                            0.0; // Convert to double

                        return Opacity(
                          opacity: 0.8, // Adjust opacity here
                          child: Card(
                            margin: EdgeInsets.only(bottom: 16.0),
                            elevation: 4.0,
                            child: ListTile(
                              title: Text('Market Place'),
                              subtitle: Text(
                                'Crop: $cropName\nPrice: $cropPrice (${crop['month_year']})\nAverage Price: ${avgPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
