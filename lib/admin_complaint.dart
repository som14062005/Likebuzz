import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminComplaint extends StatefulWidget {
  const AdminComplaint({super.key});

  @override
  State<AdminComplaint> createState() => _AdminComplaintState();
}

class _AdminComplaintState extends State<AdminComplaint> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all';
  // ignore: unused_field
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints Management',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Column(
        children: [_buildFilterBar(), Expanded(child: _buildComplaintsList())],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Filter: ',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: 8),
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Pending', 'pending'),
          SizedBox(width: 8),
          _buildFilterChip('In Progress', 'in_progress'),
          SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Color(0xFF1E3A8A),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildComplaintsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getComplaintsStream(),
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
                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No complaints found',
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
            final complaintDoc = complaints[index];
            final complaintId = complaintDoc.id;
            final complaint = complaintDoc.data() as Map<String, dynamic>;

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
              child: InkWell(
                onTap:
                    () =>
                        _showComplaintDetails(context, complaintId, complaint),
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
                                  : _capitalizeString(status),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student: ${complaint['studentName'] ?? 'Unknown'}',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Bus Route: ${complaint['busRoute'] ?? 'Not specified'}',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
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
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getComplaintsStream() {
    Query query = _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true);

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
  }

  void _showComplaintDetails(
    BuildContext context,
    String complaintId,
    Map<String, dynamic> complaint,
  ) {
    final status = complaint['status'] ?? 'pending';
    final createdAt = complaint['createdAt'] as Timestamp?;
    final formattedDate =
        createdAt != null
            ? DateFormat('MMM dd, yyyy - HH:mm').format(createdAt.toDate())
            : 'Date unavailable';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Complaint Details',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Title
                  Text(
                    complaint['title'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Student & Bus Route
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Student: ${complaint['studentName'] ?? 'Unknown'}',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_bus,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Bus Route: ${complaint['busRoute'] ?? 'Not specified'}',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Date: $formattedDate',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      complaint['description'] ?? 'No description provided.',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Status Update
                  Text(
                    'Update Status',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusButton(
                        context,
                        'Pending',
                        'pending',
                        Colors.red,
                        status,
                        complaintId,
                        setState,
                      ),
                      SizedBox(width: 8),
                      _buildStatusButton(
                        context,
                        'In Progress',
                        'in_progress',
                        Colors.orange,
                        status,
                        complaintId,
                        setState,
                      ),
                      SizedBox(width: 8),
                      _buildStatusButton(
                        context,
                        'Completed',
                        'completed',
                        Colors.green,
                        status,
                        complaintId,
                        setState,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3A8A),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Close',
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
            );
          },
        );
      },
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    String value,
    Color color,
    String currentStatus,
    String complaintId,
    StateSetter setState,
  ) {
    final isSelected = currentStatus == value;

    return Expanded(
      child: ElevatedButton(
        onPressed:
            isSelected
                ? null
                : () => _updateComplaintStatus(complaintId, value, setState),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? color : color.withAlpha((0.1 * 255).toInt()),
          foregroundColor: isSelected ? Colors.white : color,
          disabledBackgroundColor: color,
          disabledForegroundColor: Colors.white,
          elevation: isSelected ? 0 : 2,
          padding: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Method to update complaint status in Firestore
  String _capitalizeString(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  Future<void> _updateComplaintStatus(
    String complaintId,
    String newStatus,
    StateSetter modalSetState,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Update the complaint status in Firestore
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the modal state with the new status
      modalSetState(() {});

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status updated successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update status: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
