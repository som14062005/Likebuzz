// admin_leave_approval.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminLeaveApproval extends StatefulWidget {
  const AdminLeaveApproval({super.key});

  @override
  State<AdminLeaveApproval> createState() => _AdminLeaveApprovalState();
}

class _AdminLeaveApprovalState extends State<AdminLeaveApproval>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateLeaveStatus(
    String docId,
    String status,
    String feedback,
  ) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .update({
          'status': status,
          'adminFeedback': feedback,
          'updatedAt': Timestamp.now(),
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request $status'),
          backgroundColor: status == 'approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String docId,
    String driverName,
  ) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Update Leave Request',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver: $driverName'),
              SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  labelText: 'Feedback (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Reject', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _updateLeaveStatus(docId, 'rejected', feedbackController.text);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _updateLeaveStatus(docId, 'approved', feedbackController.text);
              },
              child: Text('Approve'),
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
        title: Text(
          'Driver Leave Approval',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveRequestsList('pending'),
          _buildLeaveRequestsList('approved'),
          _buildLeaveRequestsList('rejected'),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestsList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('leave_requests')
              .where('status', isEqualTo: status)
              .orderBy('submittedAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.hourglass_empty
                      : status == 'approved'
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No $status leave requests',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final data = request.data() as Map<String, dynamic>;

            final driverName = data['driverName'] as String;
            final startDate = (data['startDate'] as Timestamp).toDate();
            final endDate = (data['endDate'] as Timestamp).toDate();
            final reason = data['reason'] as String;
            final busRoute = data['busRoute'] as String;
            final feedback = data['adminFeedback'] as String? ?? '';

            return Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF1E3A8A),
                          child: Text(
                            driverName[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName.capitalize(),
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Bus Route: $busRoute',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (status == 'pending')
                          IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              _showUpdateDialog(
                                context,
                                request.id,
                                driverName,
                              );
                            },
                          ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${endDate.difference(startDate).inDays + 1} days',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Reason:',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      reason,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                    if (feedback.isNotEmpty && status != 'pending') ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedback:',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              feedback,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (status == 'pending') ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _showUpdateDialog(
                                  context,
                                  request.id,
                                  driverName,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Reject',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _showUpdateDialog(
                                  context,
                                  request.id,
                                  driverName,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1E3A8A),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// Reuse the StringExtension from your existing code
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
