import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class FuelStationsPage extends StatelessWidget {
  const FuelStationsPage({super.key});

  Future<void> _launchMapsUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // These URLs will be updated later
    final String location1Url = "https://maps.google.com/?q=location1";
    final String location2Url = "https://maps.google.com/?q=location2";
    final String location3Url = "https://maps.google.com/?q=location3";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Stations',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C3E50), Color(0xFF1A2530)],
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
                SizedBox(height: 20),

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
                    child: ListView(
                      children: [
                        Text(
                          'Partner Fuel Stations',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Location 1
                        _buildLocationCard(
                          context,
                          title: 'Location 1',
                          address: 'Update with actual location',
                          gradientColors: [
                            Color(0xFF3498DB),
                            Color(0xFF2980B9),
                          ],
                          onTap: () => _launchMapsUrl(location1Url),
                        ),

                        SizedBox(height: 16),

                        // Location 2
                        _buildLocationCard(
                          context,
                          title: 'Location 2',
                          address: 'Update with actual location',
                          gradientColors: [
                            Color(0xFF2ECC71),
                            Color(0xFF27AE60),
                          ],
                          onTap: () => _launchMapsUrl(location2Url),
                        ),

                        SizedBox(height: 16),

                        // Location 3
                        _buildLocationCard(
                          context,
                          title: 'Location 3',
                          address: 'Update with actual location',
                          gradientColors: [
                            Color(0xFFE67E22),
                            Color(0xFFD35400),
                          ],
                          onTap: () => _launchMapsUrl(location3Url),
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

  Widget _buildLocationCard(
    BuildContext context, {
    required String title,
    required String address,
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
                child: Icon(
                  Icons.local_gas_station,
                  size: 32,
                  color: Colors.white,
                ),
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
                      address,
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
              Icon(Icons.map, color: Colors.white, size: 24),
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
