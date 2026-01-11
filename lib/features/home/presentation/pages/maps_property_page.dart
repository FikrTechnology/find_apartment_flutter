import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapsPropertyPage extends StatefulWidget {
  const MapsPropertyPage({super.key});

  @override
  State<MapsPropertyPage> createState() => _MapsPropertyPageState();
}

class _MapsPropertyPageState extends State<MapsPropertyPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredResults = [];

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 100000000);
  Set<String> _selectedStatus = {};
  Set<String> _selectedLocation = {};
  Set<String> _selectedType = {};

  // Sample data
  final List<Map<String, dynamic>> _allResults = [
    {
      'title': 'Modern Apartment Downtown',
      'location': 'Jakarta',
      'address': 'Jl. Sudirman No. 123, Jakarta Selatan',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 2.450.000',
      'landArea': 'LT 45 m2',
      'buildingArea': 'LB 40 m2',
      'postTime': '2 weeks ago',
      'isBookmarked': false,
    },
    {
      'title': 'Cozy Apartment with Balcony',
      'location': 'Jakarta',
      'address': 'Jl. Gatot Subroto No. 456, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 2.100.000',
      'landArea': 'LT 36 m2',
      'buildingArea': 'LB 32 m2',
      'postTime': '1 week ago',
      'isBookmarked': false,
    },
    {
      'title': 'Spacious Family Apartment',
      'location': 'Bekasi',
      'address': 'Jl. Merdeka No. 789, Bekasi Utara',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 1.850.000',
      'landArea': 'LT 50 m2',
      'buildingArea': 'LB 45 m2',
      'postTime': '1 month ago',
      'isBookmarked': false,
    },
    {
      'title': 'Apartment Near Business District',
      'location': 'Jakarta',
      'address': 'Jl. Imam Bonjol No. 321, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 3.200.000',
      'landArea': 'LT 55 m2',
      'buildingArea': 'LB 50 m2',
      'postTime': '3 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Modern Studio Apartment',
      'location': 'Bandung',
      'address': 'Jl. Braga No. 654, Bandung',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 1.650.000',
      'landArea': 'LT 30 m2',
      'buildingArea': 'LB 28 m2',
      'postTime': '5 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Elegant 3BR Apartment with Garden',
      'location': 'Bandung',
      'address': 'Jl. Cisangkuy No. 987, Bandung',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 2.750.000',
      'landArea': 'LT 60 m2',
      'buildingArea': 'LB 55 m2',
      'postTime': '1 week ago',
      'isBookmarked': false,
    },
    {
      'title': 'Apartment with Modern Facilities',
      'location': 'Jakarta',
      'address': 'Jl. Senayan No. 147, Jakarta Selatan',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 2.900.000',
      'landArea': 'LT 48 m2',
      'buildingArea': 'LB 42 m2',
      'postTime': '10 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Furnished Apartment Ready to Move',
      'location': 'Bekasi',
      'address': 'Jl. Harapan Indah No. 258, Bekasi Barat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 2.600.000',
      'landArea': 'LT 42 m2',
      'buildingArea': 'LB 38 m2',
      'postTime': '2 days ago',
      'isBookmarked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredResults = _allResults.where((item) {
        bool matchesSearch = item['title']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        bool matchesStatus = _selectedStatus.isEmpty ||
            _selectedStatus.contains(item['status']);
        bool matchesLocation = _selectedLocation.isEmpty ||
            _selectedLocation.contains(item['location']);
        bool matchesType =
            _selectedType.isEmpty || _selectedType.contains(item['type']);
        
        // Parse price from "IDR X.XXX.XXX" format to double
        String priceStr = item['price'].replaceAll(RegExp(r'[^\d]'), '');
        double itemPrice = double.tryParse(priceStr) ?? 0;
        bool matchesPrice =
            itemPrice >= _priceRange.start && itemPrice <= _priceRange.end;

        return matchesSearch && matchesStatus && matchesLocation && matchesType && matchesPrice;
      }).toList();
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1F2937),
                size: 24,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Find property',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF6B7280),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        centerTitle: true,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Full screen map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.map,
                  size: 80,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 16),
                Text(
                  'Google Maps Integration',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Bottom sheet with property list
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and filter row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: const Text(
                                    'Xplore Property',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showFilterBottomSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Color(0xFF6366F1),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Show all property count
                          Text(
                            'Show all Property "${_filteredResults.length}"',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Property list
                    Expanded(
                      child: _filteredResults.isEmpty
                          ? Center(
                              child: Text(
                                'No properties found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              itemCount: _filteredResults.length,
                              itemBuilder: (context, index) {
                                final item = _filteredResults[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildResultCard(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // Local state untuk bottom sheet
    Set<String> tempSelectedStatus = Set.from(_selectedStatus);
    Set<String> tempSelectedLocation = Set.from(_selectedLocation);
    Set<String> tempSelectedType = Set.from(_selectedType);
    RangeValues tempPriceRange = _priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Filter Property',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Filter
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['New', 'Second'].map((status) {
                      return FilterChip(
                        label: Text(status),
                        selected: tempSelectedStatus.contains(status),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempSelectedStatus.add(status);
                            } else {
                              tempSelectedStatus.remove(status);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Location Filter
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Jakarta', 'Bekasi', 'Bandung'].map((location) {
                      return FilterChip(
                        label: Text(location),
                        selected: tempSelectedLocation.contains(location),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempSelectedLocation.add(location);
                            } else {
                              tempSelectedLocation.remove(location);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Type Filter
                  const Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Apartment', 'House', 'Ruko', 'Hotel', 'Villa']
                        .map((type) {
                      return FilterChip(
                        label: Text(type),
                        selected: tempSelectedType.contains(type),
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              tempSelectedType.add(type);
                            } else {
                              tempSelectedType.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Price Range Filter
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 100000000,
                    divisions: 100,
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempPriceRange = values;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'IDR ${(tempPriceRange.start / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'IDR ${(tempPriceRange.end / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedStatus.clear();
                              tempSelectedLocation.clear();
                              tempSelectedType.clear();
                              tempPriceRange = const RangeValues(0, 100000000);
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = tempSelectedStatus;
                              _selectedLocation = tempSelectedLocation;
                              _selectedType = tempSelectedType;
                              _priceRange = tempPriceRange;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        context.push('/property-detail', extra: item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Left side
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.6),
                    const Color(0xFF010F81).withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.apartment,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content - Right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    item['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Text(
                    item['location'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Address
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildTag(item['type'], 0xFF6366F1),
                      _buildTag(item['status'], 0xFF10B981),
                      _buildTag(item['price'], 0xFFF59E0B),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Post time
                  Text(
                    item['postTime'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark icon
            GestureDetector(
              onTap: () {
                setState(() {
                  item['isBookmarked'] = !item['isBookmarked'];
                });
              },
              child: Icon(
                item['isBookmarked']
                    ? Icons.bookmark
                    : Icons.bookmark_outline,
                color: item['isBookmarked']
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF6B7280),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, int colorHex) {
    final color = Color(colorHex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
