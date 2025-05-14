import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentComplaint extends StatefulWidget {
  const StudentComplaint({super.key});

  @override
  State<StudentComplaint> createState() => _StudentComplaintState();
}

class _StudentComplaintState extends State<StudentComplaint>
    with SingleTickerProviderStateMixin {
  String capitalizeString(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Form fields
  String _complaintTitle = '';
  String _complaintDescription = '';
  String _selectedBusRoute = '';
  List<String> routes = [
    "1",
    "1B",
    "1C",
    "2",
    "2C",
    "3",
    "3C",
    "4",
    "4C",
    "5",
    "5A",
    "5B",
    "5C",
    "6",
    "7",
    "7A",
    "7C",
    "8",
    "8C",
    "9",
    "9A",
    "9B",
    "9C",
    "10",
    "10C",
    "11",
    "11A",
    "11C",
    "12",
    "12B",
    "12C",
    "13",
    "13A",
    "13B",
    "13C",
    "14",
    "14C",
    "15",
    "15A",
    "15B",
    "15C",
    "15D",
    "15E",
    "16",
    "16A",
    "16B",
    "16C",
    "16D",
    "16E",
    "17",
    "17A",
    "17B",
    "17C",
    "17D",
    "17E",
    "18",
    "18A",
    "18B",
    "18C",
    "18D",
    "18E",
    "19",
    "19A",
    "19B",
    "19C",
    "19D",
    "19E",
    "19F",
    "20",
    "20A",
    "20B",
    "20C",
    "20D",
    "20E",
    "20F",
    "21",
    "21A",
    "21C",
    "22",
    "23",
    "23C",
    "24",
    "24C",
    "25",
    "25C",
    "26",
    "26C",
    "27",
    "27C",
    "28",
    "28C",
    "29",
    "29C",
    "30",
    "30C",
    "31",
    "32",
    "32C",
    "33",
    "33C",
    "34",
    "34C",
    "35",
    "35A",
    "35B",
    "35C",
    "35D",
    "36",
    "36C",
    "37",
    "37A",
    "37B",
    "37C",
    "37D",
    "38",
    "38C",
    "39",
    "39C",
    "40",
    "40A",
    "40B",
    "40C",
    "41",
    "41A",
    "41C",
    "42",
    "42A",
    "42C",
    "43",
    "44",
    "45",
  ];
  final bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final user = _auth.currentUser;
        final timestamp = FieldValue.serverTimestamp();

        await _firestore.collection('complaints').add({
          'userId': user?.uid,
          'studentName': user?.email?.split('@')[0] ?? 'Unknown',
          'title': _complaintTitle,
          'description': _complaintDescription,
          'busRoute': _selectedBusRoute,
          'status': 'pending',
          'createdAt': timestamp,
          'updatedAt': timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );

        // Reset form
        setState(() {
          _complaintTitle = '';
          _complaintDescription = '';
          _selectedBusRoute = routes.isNotEmpty ? routes[0] : '';
        });
        _formKey.currentState?.reset();

        // Switch to the history tab
        _tabController.animateTo(1);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit complaint: $e')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF4A69BD),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w500),
          ),
          tabs: const [
            Tab(text: 'New Complaint'),
            Tab(text: 'Complaint History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNewComplaintForm(), _buildComplaintHistory()],
      ),
    );
  }

  Widget _buildNewComplaintForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Raise a New Complaint',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bus Route Dropdown
            Text(
              'Select Bus Route',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                  value:
                      _selectedBusRoute.isNotEmpty ? _selectedBusRoute : null,
                  hint: Text('Select a bus route'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a bus route';
                    }
                    return null;
                  },
                  items:
                      routes.map((route) {
                        return DropdownMenuItem<String>(
                          value: route,
                          child: Text(route),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBusRoute = value!;
                    });
                  },
                ),
            const SizedBox(height: 24),

            // Complaint Title
            Text(
              'Complaint Title',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Enter complaint title',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _complaintTitle = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Complaint Description
            Text(
              'Complaint Description',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Describe your complaint in detail',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _complaintDescription = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A69BD),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Submit Complaint',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

  Widget _buildComplaintHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('complaints')
              .where('userId', isEqualTo: _auth.currentUser?.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final complaints = snapshot.data?.docs ?? [];

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No complaints yet',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index].data() as Map<String, dynamic>;
            final status = complaint['status'] ?? 'pending';
            final createdAt = complaint['createdAt'] as Timestamp?;
            final formattedDate =
                createdAt != null
                    ? DateFormat(
                      'MMM dd, yyyy - HH:mm',
                    ).format(createdAt.toDate())
                    : 'Date unavailable';

            // Determine status color
            Color statusColor;
            if (status == 'completed') {
              statusColor = Colors.green;
            } else if (status == 'in_progress') {
              statusColor = Colors.orange;
            } else {
              statusColor = Colors.red;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            complaint['title'] ?? 'No Title',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            status == 'in_progress'
                                ? 'In Progress'
                                : capitalizeString(status),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint['description'] ?? 'No Description',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bus Route: ${complaint['busRoute'] ?? 'Not specified'}',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
