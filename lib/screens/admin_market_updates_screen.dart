import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketUpdatesScreen extends StatefulWidget {
  @override
  _MarketUpdatesScreenState createState() => _MarketUpdatesScreenState();
}

class _MarketUpdatesScreenState extends State<MarketUpdatesScreen> {
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _crops = [];
  int _selectedPlaceId = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/places'));

      if (response.statusCode == 200) {
        setState(() {
          _places = List<Map<String, dynamic>>.from(json.decode(response.body));
          _selectedPlaceId = _places.isNotEmpty ? _places.first['id'] : 0;
          _fetchCropsByPlace(_selectedPlaceId);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load places';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCropsByPlace(int placeId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/crops/$placeId'));

      if (response.statusCode == 200) {
        setState(() {
          _crops = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load crops';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _showEditPriceDialog(Map<String, dynamic> crop) {
    final TextEditingController _priceController =
        TextEditingController(text: crop['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Price'),
          content: TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateCropPrice(
                    crop['id'], double.parse(_priceController.text));
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCropPrice(int cropId, double newPrice) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/update-price'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop_id': cropId,
        'price': newPrice,
        'month_year': '${DateTime.now().month}-${DateTime.now().year}',
      }),
    );

    if (response.statusCode == 200) {
      _fetchCropsByPlace(_selectedPlaceId);
    } else {
      // Handle the error
      print('Failed to update crop price');
    }
  }

  void _showAddPriceDialog() {
    final TextEditingController _priceController = TextEditingController();
    int _selectedPlaceId = _places.isNotEmpty ? _places.first['id'] : 0;
    int _selectedCropId = _crops.isNotEmpty ? _crops.first['id'] : 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Price'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedPlaceId,
                  items: _places.map<DropdownMenuItem<int>>((place) {
                    return DropdownMenuItem<int>(
                      value: place['id'],
                      child: Text(place['place_name']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedPlaceId = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Place'),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedCropId,
                  items: _crops.map<DropdownMenuItem<int>>((crop) {
                    return DropdownMenuItem<int>(
                      value: crop['id'],
                      child: Text(crop['crop_name']),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedCropId = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Crop'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addNewPrice(_selectedPlaceId, _selectedCropId,
                    double.parse(_priceController.text));
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewPrice(int placeId, int cropId, double price) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/add-price'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'place_id': placeId,
        'crop_id': cropId,
        'price': price,
        'month_year': '${DateTime.now().month}-${DateTime.now().year}',
      }),
    );

    if (response.statusCode == 200) {
      _fetchCropsByPlace(placeId);
    } else {
      // Handle the error
      print('Failed to add new price');
    }
  }

  void _showCropsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crops'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _crops.map<Widget>((crop) {
                return ListTile(
                  title: Text(crop['crop_name']),
                  subtitle: Text('Average Price: ${crop['avg_price']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditCropDialog(crop);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: _showAddCropDialog,
              child: Text('Add Crop'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCropDialog(Map<String, dynamic> crop) {
    final TextEditingController _avgPriceController =
        TextEditingController(text: crop['avg_price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Average Price'),
          content: TextField(
            controller: _avgPriceController,
            decoration: InputDecoration(labelText: 'Average Price'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateCropAvgPrice(
                    crop['id'], double.parse(_avgPriceController.text));
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCropAvgPrice(int cropId, double newAvgPrice) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/update-crop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop_id': cropId,
        'avg_price': newAvgPrice,
      }),
    );

    if (response.statusCode == 200) {
      _fetchCropsByPlace(_selectedPlaceId);
    } else {
      // Handle the error
      print('Failed to update crop average price');
    }
  }

  void _showAddCropDialog() {
    final TextEditingController _cropNameController = TextEditingController();
    final TextEditingController _avgPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Crop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cropNameController,
                decoration: InputDecoration(labelText: 'Crop Name'),
              ),
              TextField(
                controller: _avgPriceController,
                decoration: InputDecoration(labelText: 'Average Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addNewCrop(_cropNameController.text,
                    double.parse(_avgPriceController.text));
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewCrop(String cropName, double avgPrice) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/add-crop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop_name': cropName,
        'avg_price': avgPrice,
      }),
    );

    if (response.statusCode == 200) {
      _fetchCropsByPlace(_selectedPlaceId);
    } else {
      // Handle the error
      print('Failed to add new crop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Place'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    DropdownButton<int>(
                      value: _selectedPlaceId,
                      items: _places.map<DropdownMenuItem<int>>((place) {
                        return DropdownMenuItem<int>(
                          value: place['id'],
                          child: Text(place['place_name']),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedPlaceId = newValue!;
                          _fetchCropsByPlace(_selectedPlaceId);
                        });
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _crops.length,
                        itemBuilder: (context, index) {
                          final crop = _crops[index];
                          return ListTile(
                            title: Text(crop['crop_name']),
                            subtitle: Text('Price: ${crop['price']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditPriceDialog(crop);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPriceDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
