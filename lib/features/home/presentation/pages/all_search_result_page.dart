import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';

class AllSearchResultPage extends StatefulWidget {
  final String query;

  const AllSearchResultPage({super.key, required this.query});

  @override
  State<AllSearchResultPage> createState() => _AllSearchResultPageState();
}

class _AllSearchResultPageState extends State<AllSearchResultPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredResults = [];
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
    _searchController = TextEditingController(text: widget.query);
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
        bool matchesPrice = itemPrice >= _priceRange.start && itemPrice <= _priceRange.end;

        return matchesSearch &&
            matchesStatus &&
            matchesLocation &&
            matchesType &&
            matchesPrice;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus.clear();
      _selectedLocation.clear();
      _selectedType.clear();
      _priceRange = const RangeValues(0, 100000000);
      _applyFilters();
    });
  }

  void _showFilterBottomSheet() {
    // Local state untuk bottom sheet
    Set<String> tempSelectedStatus = Set.from(_selectedStatus);
    Set<String> tempSelectedLocation = Set.from(_selectedLocation);
    Set<String> tempSelectedType = Set.from(_selectedType);
    RangeValues tempPriceRange = _priceRange;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF1F2937),
                        size: 24,
                      ),
                    ),
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          tempSelectedStatus.clear();
                          tempSelectedLocation.clear();
                          tempSelectedType.clear();
                          tempPriceRange = const RangeValues(0, 100000000);
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: Color(0xFFE5E7EB),
                height: 1,
                thickness: 1,
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Filter
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['New', 'Second'].map((status) {
                            final isSelected = tempSelectedStatus.contains(status);
                            return FilterChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    tempSelectedStatus.add(status);
                                  } else {
                                    tempSelectedStatus.remove(status);
                                  }
                                });
                              },
                              avatar: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                              backgroundColor: const Color(0xFFF3F4F6),
                              selectedColor: const Color(0xFF6366F1),
                              elevation: isSelected ? 4 : 1,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: isSelected
                                  ? const BorderSide(color: Color(0xFF6366F1), width: 0)
                                  : const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Location Filter
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Jakarta', 'Bekasi', 'Bandung'].map((location) {
                            final isSelected = tempSelectedLocation.contains(location);
                            return FilterChip(
                              label: Text(location),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    tempSelectedLocation.add(location);
                                  } else {
                                    tempSelectedLocation.remove(location);
                                  }
                                });
                              },
                              avatar: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                              backgroundColor: const Color(0xFFF3F4F6),
                              selectedColor: const Color(0xFF6366F1),
                              elevation: isSelected ? 4 : 1,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: isSelected
                                  ? const BorderSide(color: Color(0xFF6366F1), width: 0)
                                  : const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Type Filter
                        const Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['House', 'Apartment', 'Ruko', 'Hotel', 'Villa'].map((type) {
                            final isSelected = tempSelectedType.contains(type);
                            return FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    tempSelectedType.add(type);
                                  } else {
                                    tempSelectedType.remove(type);
                                  }
                                });
                              },
                              avatar: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                              backgroundColor: const Color(0xFFF3F4F6),
                              selectedColor: const Color(0xFF6366F1),
                              elevation: isSelected ? 4 : 1,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              side: isSelected
                                  ? const BorderSide(color: Color(0xFF6366F1), width: 0)
                                  : const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Price Range Filter
                        const Text(
                          'Price Range',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'IDR ${(tempPriceRange.start / 1000000).toStringAsFixed(1)}M - IDR ${(tempPriceRange.end / 1000000).toStringAsFixed(1)}M',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                          labels: RangeLabels(
                            'IDR ${(tempPriceRange.start / 1000000).toStringAsFixed(1)}M',
                            'IDR ${(tempPriceRange.end / 1000000).toStringAsFixed(1)}M',
                          ),
                          activeColor: const Color(0xFF6366F1),
                          inactiveColor: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 24),
                        // Apply Filter Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF1A28CB),
                                  Color(0xFF010F81),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FilledButton(
                              onPressed: () {
                                // Apply the temporary selections to the main state
                                setState(() {
                                  _selectedStatus = tempSelectedStatus;
                                  _selectedLocation = tempSelectedLocation;
                                  _selectedType = tempSelectedType;
                                  _priceRange = tempPriceRange;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Text(
                                'Apply Filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF1F2937),
                size: 24,
              ),
              onPressed: () => context.go('/search-result?q=${_searchController.text}'),
            ),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: AppStrings.findProperty,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filter button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All result: ${_filteredResults.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
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
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Results list
            Expanded(
              child: _filteredResults.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    )
                  : ListView.builder(
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
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return Container(
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
                  const Color(0xFF6366F1).withOpacity(0.6),
                  const Color(0xFF010F81).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.apartment,
                color: Colors.white.withOpacity(0.4),
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
                    _buildTag(item['type']),
                    _buildTag(item['status']),
                    _buildTag(item['price']),
                  ],
                ),
                const SizedBox(height: 6),
                // More tags
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildTag(item['landArea']),
                    _buildTag(item['buildingArea']),
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
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}
