import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FuelCostUpdate extends StatefulWidget {
  const FuelCostUpdate({super.key});

  @override
  State<FuelCostUpdate> createState() => _FuelCostUpdateState();
}

class _FuelCostUpdateState extends State<FuelCostUpdate> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _busRouteController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // For statistics
  double _totalFuelUsed = 0;
  double _totalCost = 0;
  Map<String, double> _fuelByRoute = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _litersController.dispose();
    _busRouteController.dispose();
    _costController.dispose();
    super.dispose();
  }

  // Load fuel statistics based on selected route
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all fuel records
      final QuerySnapshot fuelRecords =
          await FirebaseFirestore.instance.collection('fuel_records').get();

      double totalFuel = 0;
      double totalCost = 0;
      Map<String, double> fuelByRoute = {};

      for (var doc in fuelRecords.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double liters = (data['liters'] as num).toDouble();
        String route = data['busRoute'] as String;
        double cost =
            data['cost'] != null ? (data['cost'] as num).toDouble() : 0;

        totalFuel += liters;
        totalCost += cost;

        if (fuelByRoute.containsKey(route)) {
          fuelByRoute[route] = (fuelByRoute[route] ?? 0) + liters;
        } else {
          fuelByRoute[route] = liters;
        }
      }

      setState(() {
        _totalFuelUsed = totalFuel;
        _totalCost = totalCost;
        _fuelByRoute = fuelByRoute;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading fuel statistics: $e')),
      );
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2C3E50),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Submit fuel record
  Future<void> _submitFuelRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse values
      final double liters = double.parse(_litersController.text);
      final String busRoute = _busRouteController.text;
      final double cost =
          _costController.text.isNotEmpty
              ? double.parse(_costController.text)
              : 0;

      // Create new fuel record
      await FirebaseFirestore.instance.collection('fuel_records').add({
        'driverId': currentUser?.uid,
        'driverName':
            currentUser?.email?.split('@')[0].capitalize() ?? 'Unknown',
        'date': Timestamp.fromDate(_selectedDate),
        'liters': liters,
        'busRoute': busRoute,
        'cost': cost,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reset form and reload stats
      _litersController.clear();
      _costController.clear();
      _loadStatistics();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fuel record added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding fuel record: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Cost Update',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Fuel Usage',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Record daily fuel consumption by route',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withAlpha(
                                  (0.9 * 255).toInt(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form section
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fuel Details',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Date picker
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat(
                                    'EEEE, MMMM d, yyyy',
                                  ).format(_selectedDate),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Bus route field
                            TextFormField(
                              controller: _busRouteController,
                              decoration: InputDecoration(
                                labelText: 'Bus Route Number',
                                hintText: 'Enter bus route',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.route),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter bus route';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Liters field
                            TextFormField(
                              controller: _litersController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Liters of Fuel',
                                hintText: 'Enter amount in liters',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.local_gas_station),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter fuel amount';
                                }
                                try {
                                  double.parse(value);
                                } catch (e) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Cost field
                            TextFormField(
                              controller: _costController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cost (optional)',
                                hintText: 'Enter fuel cost',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  try {
                                    double.parse(value);
                                  } catch (e) {
                                    return 'Please enter a valid number';
                                  }
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submitFuelRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2ECC71),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  'Submit Fuel Record',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Statistics section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.1 * 255).toInt()),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fuel Usage Statistics',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: Color(0xFF2C3E50),
                                ),
                                onPressed: _loadStatistics,
                                tooltip: 'Refresh statistics',
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Stats cards
                          Row(
                            children: [
                              _buildStatCard(
                                'Total Fuel',
                                '${_totalFuelUsed.toStringAsFixed(2)} L',
                                Icons.local_gas_station,
                                Colors.blue,
                              ),
                              SizedBox(width: 16),
                              _buildStatCard(
                                'Total Cost',
                                '\$${_totalCost.toStringAsFixed(2)}',
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ],
                          ),

                          SizedBox(height: 24),
                          Text(
                            'Fuel Usage by Route',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),

                          // Fuel by route list
                          ..._fuelByRoute.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_bus,
                                    color: Color(0xFF2C3E50),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Route ${entry.key}:',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${entry.value.toStringAsFixed(2)} L',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_fuelByRoute.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No fuel data available yet',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Helper method to build stat cards
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color.withAlpha((0.8 * 255).toInt()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension method to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
