import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MarketUpdatesScreen extends StatefulWidget {
  @override
  _MarketUpdatesScreenState createState() => _MarketUpdatesScreenState();
}

class _MarketUpdatesScreenState extends State<MarketUpdatesScreen> {
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _allCrops = [];
  int _selectedPlaceId = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/places'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _places = List<Map<String, dynamic>>.from(data);
          _selectedPlaceId = _places.isNotEmpty ? _places.first['id'] ?? 0 : 0;
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
      _errorMessage = '';
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/crops/$placeId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _crops = List<Map<String, dynamic>>.from(data);
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

  Future<void> _fetchAllCrops() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.5.1:3000/all-crops'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allCrops = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print('Failed to load all crops');
      }
    } catch (e) {
      print('An error occurred. Please try again later.');
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
      print('Failed to update crop price');
    }
  }

  void _showAddPriceDialog() {
    final TextEditingController _priceController = TextEditingController();
    int? _selectedCropId;
    int? _selectedPlaceIdForAdd = _selectedPlaceId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Price'),
              content: FutureBuilder(
                future: _fetchAllCrops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load crops'));
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<int>(
                          value: _selectedPlaceIdForAdd,
                          hint: Text('Select Place'),
                          items: _places.map<DropdownMenuItem<int>>((place) {
                            return DropdownMenuItem<int>(
                              value: place['id'],
                              child: Text(place['place_name']),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedPlaceIdForAdd = newValue;
                            });
                          },
                        ),
                        DropdownButton<int>(
                          value: _selectedCropId,
                          hint: Text('Select Crop'),
                          items: _allCrops.map<DropdownMenuItem<int>>((crop) {
                            return DropdownMenuItem<int>(
                              value: crop['id'],
                              child: Text(crop['crop_name']),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedCropId = newValue;
                            });
                          },
                        ),
                        TextField(
                          controller: _priceController,
                          decoration: InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    );
                  }
                },
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
                    if (_selectedCropId != null &&
                        _selectedPlaceIdForAdd != null &&
                        _priceController.text.isNotEmpty) {
                      _addCropPrice(
                        _selectedCropId!,
                        _selectedPlaceIdForAdd!,
                        double.parse(_priceController.text),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addCropPrice(int cropId, int placeId, double price) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.5.1:3000/add-price'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'crop_id': cropId,
          'place_id': placeId,
          'price': price,
          'month_year': DateFormat('MMMM yyyy').format(DateTime.now()),
        }),
      );

      if (response.statusCode == 200) {
        _fetchCropsByPlace(_selectedPlaceId);
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        _showErrorDialog(responseData['error']);
      } else {
        print('Failed to add crop price');
      }
    } catch (e) {
      print('An error occurred. Please try again later.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Place'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
