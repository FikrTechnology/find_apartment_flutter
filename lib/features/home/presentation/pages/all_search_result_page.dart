import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/location_dropdown.dart';
import '../../../property/presentation/bloc/property_list_bloc.dart';
import '../../../../core/api/models/property_list_models.dart';

class AllSearchResultPage extends StatefulWidget {
  final String query;

  const AllSearchResultPage({super.key, required this.query});

  @override
  State<AllSearchResultPage> createState() => _AllSearchResultPageState();
}

class _AllSearchResultPageState extends State<AllSearchResultPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  RangeValues _priceRange = const RangeValues(0, 100000000);
  Set<String> _selectedStatus = {};
  Set<String> _selectedLocation = {};
  Set<String> _selectedType = {};
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    _scrollController = ScrollController();
    
    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);
    
    // Clear filters first
    _selectedStatus.clear();
    _selectedLocation.clear();
    _selectedType.clear();
    _priceRange = const RangeValues(0, 50000000000);
    
    // Schedule load on next frame - ensures context is ready
    Future.microtask(() {
      _loadProperties();
    });
  }

  void _onScroll() {
    // Detect when user scrolls to bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      // Load more if not already loading
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        context.read<PropertyListBloc>().add(LoadMorePropertiesEvent());
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadProperties() {
    final searchText = _searchController.text;
    
    // Only send filter params if they're actually set by user
    final hasFilters = _selectedStatus.isNotEmpty || 
                      _selectedType.isNotEmpty ||
                      (_priceRange.start > 0 || _priceRange.end < 50000000000);
    
    context.read<PropertyListBloc>().add(
      FetchPropertiesEvent(
        search: searchText.isNotEmpty ? searchText : null,
        status: _selectedStatus.isNotEmpty ? _selectedStatus.first : null,
        type: _selectedType.isNotEmpty ? _selectedType.first : null,
        priceMin: hasFilters && _priceRange.start > 0 ? _priceRange.start.toInt() : null,
        priceMax: hasFilters && _priceRange.end < 50000000000 ? _priceRange.end.toInt() : null,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                          tempPriceRange = const RangeValues(0, 50000000000);
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
                        LocationDropdown(
                          locations: ['Jakarta', 'Bekasi', 'Bandung', 'Surabaya', 'Medan', 'Semarang'],
                          selectedLocations: tempSelectedLocation,
                          onChanged: (selected) {
                            setModalState(() {
                              tempSelectedLocation = selected;
                            });
                          },
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
                          max: 50000000000,
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
                                });
                                _loadProperties();
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
            onChanged: (_) => _loadProperties(),
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
                BlocBuilder<PropertyListBloc, PropertyListState>(
                  builder: (context, state) {
                    int count = 0;
                    if (state is PropertyListLoaded) {
                      count = state.properties.length;
                    }
                    return Text(
                      'All result: $count',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    );
                  },
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
              child: BlocBuilder<PropertyListBloc, PropertyListState>(
                builder: (context, state) {
                  if (state is PropertyListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is PropertyListError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    );
                  }

                  if (state is PropertyListLoaded) {
                    final properties = state.properties;
                    if (properties.isEmpty) {
                      return Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }

                    // Reset loading flag when new data arrives
                    _isLoadingMore = false;

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: properties.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index == properties.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Column(
                                children: const [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6366F1),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Loading more...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final property = properties[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildResultCard(property),
                        );
                      },
                    );
                  }

                  // Handle initial or unknown state
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Property property) {
    return GestureDetector(
      onTap: () {
        // Convert Property to Map for compatibility with existing detail page
        final propertyMap = {
          'id': property.id,
          'title': property.name,
          'location': property.address.split(',').first,
          'address': property.address,
          'type': property.type,
          'status': property.status,
          'price': 'IDR ${property.price.toStringAsFixed(0)}',
          'landArea': 'LT ${property.landArea ?? 0} m2',
          'buildingArea': 'LB ${property.buildingArea ?? 0} m2',
          'postTime': property.postedAt ?? 'Recently',
          'isBookmarked': false,
          'description': property.description,
          'images': property.imageUrl,
        };
        context.push('/all-search-result/detail', extra: propertyMap);
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
                    property.name,
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
                    property.address.split(',').first,
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
                          property.address,
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
                    _buildTag(property.type),
                    _buildTag(property.status),
                    _buildTag('IDR ${property.price.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 6),
                // More tags
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildTag('LT ${property.landArea} m2'),
                    _buildTag('LB ${property.buildingArea} m2'),
                  ],
                ),
                const SizedBox(height: 6),
                // Post time
                Text(
                  property.postedAt ?? 'Recently',
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
            onTap: () {},
            child: Icon(
              Icons.bookmark_outline,
              color: const Color(0xFF6B7280),
              size: 22,
            ),
          ),
          ],
        ),
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
