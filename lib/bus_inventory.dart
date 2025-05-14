import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Extension method to capitalize the first letter of a string.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class BusPartsInventory extends StatefulWidget {
  final bool isAdmin;

  const BusPartsInventory({super.key, required this.isAdmin});

  @override
  BusPartsInventoryState createState() => BusPartsInventoryState();
}

class BusPartsInventoryState extends State<BusPartsInventory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'All';
  List<String> _categories = ['All'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      await _firestore.collection('parts_categories').get();
      setState(() {
        _categories = [
          'All',
          'Engine',
          'Brakes',
          'Suspension',
          'Electrical',
          'Body',
          'Other',
        ];
      });
    } catch (e) {
      setState(() {
        _categories = [
          'All',
          'Engine',
          'Brakes',
          'Suspension',
          'Electrical',
          'Body',
          'Other',
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bus Parts Inventory',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor:
            widget.isAdmin ? const Color(0xFF1E3A8A) : const Color(0xFF2C3E50),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.inbox),
              tooltip: 'View Part Requests',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PartRequestsPage(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color:
                widget.isAdmin
                    ? const Color(0xFF1E3A8A).withAlpha((0.05 * 255).toInt())
                    : const Color(0xFF2C3E50).withAlpha((0.05 * 255).toInt()),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Parts',
                hintText: 'Enter part name or number',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color:
                        widget.isAdmin
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF2C3E50),
                    width: 2.0,
                  ),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _categoryFilter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    backgroundColor: Colors.grey.shade200,
                    selectedColor:
                        widget.isAdmin
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF2C3E50),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _categoryFilter = category;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildInventoryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPartDialog(context),
        backgroundColor:
            widget.isAdmin ? const Color(0xFF1E3A8A) : const Color(0xFF2C3E50),
        tooltip: widget.isAdmin ? 'Add New Part' : 'Request Part',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryList() {
    Query query = _firestore.collection('parts_inventory');

    if (_categoryFilter != 'All') {
      query = query.where('category', isEqualTo: _categoryFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No parts found',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (widget.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Add parts to the inventory',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        final parts = snapshot.data!.docs;

        final filteredParts =
            _searchQuery.isEmpty
                ? parts
                : parts.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'].toString().toLowerCase();
                  final partNumber =
                      data['partNumber']?.toString().toLowerCase() ?? '';
                  final description =
                      data['description']?.toString().toLowerCase() ?? '';
                  final searchLower = _searchQuery.toLowerCase();

                  return name.contains(searchLower) ||
                      partNumber.contains(searchLower) ||
                      description.contains(searchLower);
                }).toList();

        if (filteredParts.isEmpty) {
          return Center(
            child: Text(
              'No parts match your search',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: filteredParts.length,
          itemBuilder: (context, index) {
            final doc = filteredParts[index];
            final data = doc.data() as Map<String, dynamic>;
            final partId = doc.id;
            final name = data['name'] ?? 'Unknown Part';
            final quantity = data['quantity'] ?? 0;
            final category = data['category'] ?? 'Uncategorized';
            final partNumber = data['partNumber'] ?? '-';
            final minQuantity = data['minQuantity'] ?? 5;
            final description = data['description'] ?? '';
            final isLowStock = quantity <= minQuantity;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _showPartDetailsDialog(context, partId, data),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getCategoryIcon(category),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLowStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Low Stock',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Part #: $partNumber',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(fontSize: 13),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Quantity: ',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isLowStock
                                                  ? Colors.red
                                                  : Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'engine':
        iconData = Icons.settings;
        iconColor = Colors.red.shade700;
        break;
      case 'brakes':
        iconData = Icons.do_not_step;
        iconColor = Colors.orange.shade700;
        break;
      case 'suspension':
        iconData = Icons.waves;
        iconColor = Colors.blue.shade700;
        break;
      case 'electrical':
        iconData = Icons.electrical_services;
        iconColor = Colors.yellow.shade700;
        break;
      case 'body':
        iconData = Icons.directions_bus;
        iconColor = Colors.green.shade700;
        break;
      default:
        iconData = Icons.build;
        iconColor = Colors.purple.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Filter Parts',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _categories.map((category) {
                          final isSelected = category == _categoryFilter;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor:
                                widget.isAdmin
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFF2C3E50),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _categoryFilter = category;
                                });
                                Navigator.pop(context);
                              }
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Future<void> _showAddPartDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final descriptionController = TextEditingController();
    final partNumberController = TextEditingController();
    final minQuantityController = TextEditingController(text: '5');
    String selectedCategory = _categories.length > 1 ? _categories[1] : 'Other';

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    widget.isAdmin ? 'Add New Part' : 'Request Part',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Part Name*',
                            hintText: 'Enter part name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: partNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Part Number',
                            hintText: 'Enter part number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText:
                                widget.isAdmin
                                    ? 'Quantity*'
                                    : 'Requested Quantity*',
                            hintText: 'Enter quantity',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.isAdmin) ...[
                          TextField(
                            controller: minQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Quantity',
                              hintText: 'Enter minimum stock level',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Category*',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _categories
                                  .where((category) => category != 'All')
                                  .map((category) {
                                    final isSelected =
                                        category == selectedCategory;
                                    return ChoiceChip(
                                      label: Text(category),
                                      selected: isSelected,
                                      selectedColor:
                                          widget.isAdmin
                                              ? const Color(0xFF1E3A8A)
                                              : const Color(0xFF2C3E50),
                                      labelStyle: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            selectedCategory = category;
                                          });
                                        }
                                      },
                                    );
                                  })
                                  .toList(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter part description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.isAdmin
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF2C3E50),
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Part name is required'),
                                    ),
                                  );
                                  return;
                                }

                                if (quantityController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Quantity is required'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final int quantity =
                                      int.tryParse(
                                        quantityController.text.trim(),
                                      ) ??
                                      0;
                                  final int minQuantity =
                                      int.tryParse(
                                        minQuantityController.text.trim(),
                                      ) ??
                                      5;

                                  if (widget.isAdmin) {
                                    final String partId = nameController.text
                                        .trim()
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'[^\w\s]+'), '')
                                        .replaceAll(' ', '_');

                                    await _firestore
                                        .collection('parts_inventory')
                                        .doc(partId)
                                        .set({
                                          'name': nameController.text.trim(),
                                          'quantity': quantity,
                                          'minQuantity': minQuantity,
                                          'category': selectedCategory,
                                          'description':
                                              descriptionController.text.trim(),
                                          'partNumber':
                                              partNumberController.text.trim(),
                                          'lastUpdated':
                                              FieldValue.serverTimestamp(),
                                          'updatedBy':
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.email ??
                                              'admin',
                                        }, SetOptions(merge: true));

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Part successfully added/updated',
                                        ),
                                      ),
                                    );
                                  } else {
                                    await _firestore
                                        .collection('part_requests')
                                        .add({
                                          'partName':
                                              nameController.text.trim(),
                                          'requestedQuantity': quantity,
                                          'category': selectedCategory,
                                          'description':
                                              descriptionController.text.trim(),
                                          'partNumber':
                                              partNumberController.text.trim(),
                                          'requestedBy':
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.email ??
                                              'unknown',
                                          'requestedAt':
                                              FieldValue.serverTimestamp(),
                                          'status': 'pending',
                                        });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Part request submitted successfully',
                                        ),
                                      ),
                                    );
                                  }

                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },

                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                widget.isAdmin ? 'Add Part' : 'Request Part',
                              ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showPartDetailsDialog(
    BuildContext context,
    String partId,
    Map<String, dynamic> data,
  ) {
    // ...existing code...
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class PartRequestsPage extends StatefulWidget {
  const PartRequestsPage({super.key});

  @override
  PartRequestsPageState createState() => PartRequestsPageState();
}

class PartRequestsPageState extends State<PartRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _statusFilter = 'All';
  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Part Requests',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusOptions.length,
              itemBuilder: (context, index) {
                final status = _statusOptions[index];
                final isSelected = status == _statusFilter;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: const Color(0xFF1E3A8A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _statusFilter = status;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    Query query = _firestore
        .collection('part_requests')
        .orderBy('requestedAt', descending: true);

    if (_statusFilter != 'All') {
      query = query.where('status', isEqualTo: _statusFilter.toLowerCase());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No part requests found',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            final partName = data['partName'] ?? 'Unknown Part';
            final requestedQuantity = data['requestedQuantity'] ?? 0;
            final category = data['category'] ?? 'Uncategorized';
            final description = data['description'] ?? '';
            final partNumber = data['partNumber'] ?? '-';
            final requestedBy = data['requestedBy'] ?? 'Unknown';
            final status = data['status'] ?? 'pending';
            final requestedAt = data['requestedAt'] as Timestamp?;
            final formattedDate =
                requestedAt != null
                    ? DateFormat('MMM d, yyyy').format(requestedAt.toDate())
                    : 'Unknown date';

            Color statusColor;
            switch (status) {
              case 'approved':
                statusColor = Colors.green.shade700;
                break;
              case 'rejected':
                statusColor = Colors.red.shade700;
                break;
              default:
                statusColor = Colors.orange.shade700;
            }

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _showRequestDetailsDialog(context, doc.id, data),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getCategoryIcon(category),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        partName,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.toString().capitalize(),
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (partNumber != '-') ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Part #: $partNumber',
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Requested by: $requestedBy',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: $formattedDate',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(fontSize: 13),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Qty: $requestedQuantity',
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case 'engine':
        iconData = Icons.settings;
        iconColor = Colors.red.shade700;
        break;
      case 'brakes':
        iconData = Icons.do_not_step;
        iconColor = Colors.orange.shade700;
        break;
      case 'suspension':
        iconData = Icons.waves;
        iconColor = Colors.blue.shade700;
        break;
      case 'electrical':
        iconData = Icons.electrical_services;
        iconColor = Colors.yellow.shade700;
        break;
      case 'body':
        iconData = Icons.directions_bus;
        iconColor = Colors.green.shade700;
        break;
      default:
        iconData = Icons.build;
        iconColor = Colors.purple.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: iconColor, size: 28),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Filter by Status',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Status',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _statusOptions.map((status) {
                          final isSelected = status == _statusFilter;
                          return ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E3A8A),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _statusFilter = status;
                                });
                                Navigator.pop(context);
                              }
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showRequestDetailsDialog(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    final partName = data['partName'] ?? 'Unknown Part';
    final requestedQuantity = data['requestedQuantity'] ?? 0;
    final category = data['category'] ?? 'Uncategorized';
    final description = data['description'] ?? '';
    final partNumber = data['partNumber'] ?? '-';
    final requestedBy = data['requestedBy'] ?? 'Unknown';
    final status = data['status'] ?? 'pending';
    final requestedAt = data['requestedAt'] as Timestamp?;
    final formattedDate =
        requestedAt != null
            ? DateFormat('MMM d, yyyy h:mm a').format(requestedAt.toDate())
            : 'Unknown date';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    'Part Request Details',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Part Name', partName),
                        if (partNumber != '-')
                          _buildDetailRow('Part Number', partNumber),
                        _buildDetailRow('Category', category),
                        _buildDetailRow(
                          'Requested Quantity',
                          requestedQuantity.toString(),
                        ),
                        _buildDetailRow('Requested By', requestedBy),
                        _buildDetailRow('Date', formattedDate),
                        _buildDetailRow(
                          'Status',
                          status.toString().capitalize(),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Description:',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if (status == 'pending') ...[
                          Text(
                            'Update Status:',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                ),
                                onPressed:
                                    () => _updateRequestStatus(
                                      requestId,
                                      'rejected',
                                    ),
                                child: const Text('Reject'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                                onPressed:
                                    () => _updateRequestStatus(
                                      requestId,
                                      'approved',
                                    ),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontSize: 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('part_requests').doc(requestId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request ${newStatus.toString().capitalize()} successfully',
          ),
        ),
      );

      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request ${newStatus.toString().capitalize()} successfully',
          ),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
