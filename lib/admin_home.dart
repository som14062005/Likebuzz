import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_leave_approval.dart';
import 'bus_inventory.dart';
import 'admin_complaint.dart';

class AdminHome extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF0F172A),
                ], // Darker blue for admin
              ),
            ),
          ),

          // Top decorative wave shape
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.15 * 255).toInt()),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar with transparent background
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and title
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    (0.1 * 255).toInt(),
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFF1E3A8A),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Admin Portal',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Logout button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.exit_to_app, color: Colors.white),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Greeting section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withAlpha(
                                (0.9 * 255).toInt(),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${StringExtension(currentUser?.email?.split('@')[0] ?? '').capitalize()}!',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main content area with cards
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 24),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).toInt()),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Services',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        Expanded(
                          child: ListView(
                            children: [
                              // Complaints Management
                              _buildOptionCard(
                                context,
                                title: 'Complaints',
                                subtitle:
                                    'View and manage driver and customer complaints',
                                icon: Icons.report_problem,
                                gradientColors: [
                                  Color(0xFFE74C3C),
                                  Color(0xFFC0392B),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminComplaint(),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 16),

                              // Driver Leave Approval
                              _buildOptionCard(
                                context,
                                title: 'Driver Leave Approval',
                                subtitle:
                                    'Review and approve driver leave requests',
                                icon: Icons.event_available,
                                gradientColors: [
                                  Color(0xFF9B59B6),
                                  Color(0xFF8E44AD),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AdminLeaveApproval(),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 16),

                              // Bus Rescheduling
                              _buildOptionCard(
                                context,
                                title: 'Bus Rescheduling',
                                subtitle: 'Manage and change bus schedules',
                                icon: Icons.schedule,
                                gradientColors: [
                                  Color(0xFF3498DB),
                                  Color(0xFF2980B9),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PlaceholderPage(
                                            'Bus Rescheduling',
                                          ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 16),

                              // Bus Parts Inventory
                              _buildOptionCard(
                                context,
                                title: 'Bus Parts Inventory',
                                subtitle:
                                    'Manage parts inventory and approve requests',
                                icon: Icons.inventory,
                                gradientColors: [
                                  Color(0xFF2ECC71),
                                  Color(0xFF27AE60),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              BusPartsInventory(isAdmin: true),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: gradientColors.first.withAlpha((0.3 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withAlpha((0.3 * 255).toInt()),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).toInt()),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.9 * 255).toInt()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Wave shape clipper for the top decoration
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);

    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// This is just a placeholder for the pages you'll create
// Replace this with your actual implementation pages
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title Page',
          style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
