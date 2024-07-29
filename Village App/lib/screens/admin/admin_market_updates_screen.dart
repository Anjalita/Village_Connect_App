import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

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
        'month_year': DateFormat('MMMM yyyy').format(DateTime.now()),
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
        _fetchCropsByPlace(placeId);
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

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(error),
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

  void _showPopupMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.update),
                title: Text('Update Average'),
                onTap: () {
                  Navigator.pop(context);
                  _showUpdateAverageDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text('Add New Crop'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCropDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateAverageDialog() {
    final TextEditingController _averagePriceController =
        TextEditingController();
    int? _selectedCropId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Average Price'),
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
                        DropdownButtonFormField<int>(
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _averagePriceController,
                          decoration: InputDecoration(
                            labelText: 'Average Price',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(),
                          ),
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
                        _averagePriceController.text.isNotEmpty) {
                      _updateAveragePrice(
                        _selectedCropId!,
                        double.parse(_averagePriceController.text),
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

  Future<void> _updateAveragePrice(int cropId, double averagePrice) async {
    final response = await http.post(
      Uri.parse('http://192.168.5.1:3000/update-average-price'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'crop_id': cropId,
        'average_price': averagePrice,
      }),
    );

    if (response.statusCode == 200) {
      _fetchCropsByPlace(_selectedPlaceId);
    } else {
      print('Failed to update average price');
    }
  }

  void _showAddCropDialog() {
    final TextEditingController _cropNameController = TextEditingController();
    final TextEditingController _averagePriceController =
        TextEditingController();

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
                decoration: InputDecoration(
                  labelText: 'Crop Name',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _averagePriceController,
                decoration: InputDecoration(
                  labelText: 'Average Price',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(),
                ),
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
                    _averagePriceController.text.isNotEmpty) {
                  _addNewCrop(
                    _cropNameController.text,
                    double.parse(_averagePriceController.text),
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
  }

  Future<void> _addNewCrop(String cropName, double averagePrice) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.5.1:3000/add-crop'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'crop_name': cropName,
          'average_price': averagePrice,
        }),
      );

      if (response.statusCode == 200) {
        _fetchAllCrops();
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        _showErrorDialog(responseData['error']);
      } else {
        print('Failed to add new crop');
      }
    } catch (e) {
      print('An error occurred. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Market Place'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/admin.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                BlendMode.lighten),
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<int>(
                          value: _selectedPlaceId,
                          hint: Text('Select Location'),
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _crops.length,
                          itemBuilder: (context, index) {
                            final crop = _crops[index];
                            return Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    width: 1.0),
                              ),
                              child: ListTile(
                                title: Text(crop['crop_name']),
                                subtitle: Text(
                                    'Price: ${crop['price']}\nAverage Price: ${crop['avg_price']}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditPriceDialog(crop);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'updateAverage',
            onPressed: _showPopupMenu,
            child: Icon(Icons.more_vert),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addCropPrice',
            onPressed: _showAddPriceDialog,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
