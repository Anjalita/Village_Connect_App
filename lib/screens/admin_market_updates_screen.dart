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
    _fetchAllCrops();
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

  void _showCropOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crop Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Update Average'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateAverageDialog();
                },
              ),
              ListTile(
                title: Text('Add New Crop'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddNewCropDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateAverageDialog() {
    final TextEditingController _avgPriceController = TextEditingController();
    int? _selectedCropId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Crop Average'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        print(
                            'Selected Crop ID: $_selectedCropId'); // Debugging
                      });
                    },
                  ),
                  TextField(
                    controller: _avgPriceController,
                    decoration: InputDecoration(labelText: 'Average Price'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
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
                    _avgPriceController.text.isNotEmpty) {
                  _updateCropAverage(
                      _selectedCropId!, double.parse(_avgPriceController.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCropAverage(int cropId, double avgPrice) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/update-crop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop_id': cropId,
        'avg_price': avgPrice,
      }),
    );

    if (response.statusCode == 200) {
      _fetchAllCrops(); // Refresh the list of all crops
    } else {
      print('Failed to update crop average price');
    }
  }

  void _showAddNewCropDialog() {
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
                if (_cropNameController.text.isNotEmpty &&
                    _avgPriceController.text.isNotEmpty) {
                  _addNewCrop(
                    _cropNameController.text,
                    double.parse(_avgPriceController.text),
                    context,
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewCrop(
      String cropName, double avgPrice, BuildContext context) async {
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
      // Crop added successfully
      _fetchAllCrops(); // Refresh the list of all crops
      Navigator.pop(context); // Close the dialog
    } else if (response.statusCode == 400) {
      // Crop already exists
      Navigator.pop(context); // Close the dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Crop already exists'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Failed to add new crop
      Navigator.pop(context); // Close the dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to add new crop'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
                            subtitle: Text(
                                'Price: ${crop['price']}\nAverage Price: ${crop['avg_price']}'),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddPriceDialog,
            child: Icon(Icons.add),
            heroTag: null, // Ensure unique hero tag if multiple FABs are used
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _showCropOptionsDialog,
            child: Icon(Icons.more_horiz),
            heroTag: null, // Ensure unique hero tag if multiple FABs are used
          ),
        ],
      ),
    );
  }
}
