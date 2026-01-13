import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../property/presentation/bloc/property_list_bloc.dart';
import '../../../../core/api/models/property_list_models.dart';

class MapsPropertyPage extends StatefulWidget {
  const MapsPropertyPage({super.key});

  @override
  State<MapsPropertyPage> createState() => _MapsPropertyPageState();
}

class _MapsPropertyPageState extends State<MapsPropertyPage> {
  late TextEditingController _searchController;
  late MapController _mapController;
  late ScrollController _scrollController;

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 50000000000);
  Set<String> _selectedStatus = {};
  Set<String> _selectedLocation = {};
  Set<String> _selectedType = {};
  bool _isLoadingMore = false;
  
  // Default center (Jakarta)
  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();
    _scrollController = ScrollController();
    
    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);
    
    _loadProperties();
  }

  void _onScroll() {
    // Detect when user scrolls to bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      // Load more if not already loading
      if (!_isLoadingMore) {
        _isLoadingMore = true;
        print('📜 MapsPropertyPage: Infinite scroll triggered - loading more');
        context.read<PropertyListBloc>().add(LoadMorePropertiesEvent());
      }
    }
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
    _mapController.dispose();
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
                              onSelected: (value) {
                                setModalState(() {
                                  if (value) {
                                    tempSelectedStatus.add(status);
                                  } else {
                                    tempSelectedStatus.remove(status);
                                  }
                                });
                              },
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
                        RangeSlider(
                          values: tempPriceRange,
                          min: 0,
                          max: 50000000000,
                          divisions: 100,
                          labels: RangeLabels(
                            'IDR ${tempPriceRange.start.toInt()}',
                            'IDR ${tempPriceRange.end.toInt()}',
                          ),
                          onChanged: (value) {
                            setModalState(() {
                              tempPriceRange = value;
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
                          children: ['Apartment', 'House', 'Kos'].map((type) {
                            final isSelected = tempSelectedType.contains(type);
                            return FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (value) {
                                setModalState(() {
                                  if (value) {
                                    tempSelectedType.add(type);
                                  } else {
                                    tempSelectedType.remove(type);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SizedBox(
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
                        setState(() {
                          _selectedStatus = tempSelectedStatus;
                          _selectedLocation = tempSelectedLocation;
                          _selectedType = tempSelectedType;
                          _priceRange = tempPriceRange;
                          _loadProperties();
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
              onPressed: () {
                try {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                } catch (e) {
                  print('❌ Maps page back button error: $e');
                  context.go('/home');
                }
              },
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
            onChanged: (_) => _loadProperties(),
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
          // Leaflet Map with Property Markers
          BlocBuilder<PropertyListBloc, PropertyListState>(
            builder: (context, state) {
              List<Marker> markers = [];
              
              if (state is PropertyListLoaded) {
                markers = state.properties
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final property = entry.value;
                      // Generate random coordinates around Jakarta for demo
                      final lat = -6.2088 + (index % 10) * 0.01;
                      final lng = 106.8456 + (index % 10) * 0.01;
                      
                      return Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(lat, lng),
                        child: GestureDetector(
                          onTap: () {
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
                            context.push('/maps-property/detail', extra: propertyMap);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF010F81),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'IDR ${(property.price / 1000000000).toStringAsFixed(0)}B',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList();
              }
              
              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: 13,
                  minZoom: 5,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.find_apartment_flutter',
                    tileProvider: NetworkTileProvider(),
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
          ),

          // Bottom sheet with property list
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, sheetScrollController) {
              // Setup listener for infinite scroll on sheet scroll
              if (!sheetScrollController.hasListeners) {
                sheetScrollController.addListener(() {
                  if (sheetScrollController.position.pixels >= 
                      sheetScrollController.position.maxScrollExtent - 500) {
                    if (!_isLoadingMore) {
                      _isLoadingMore = true;
                      print('📜 MapsPropertyPage: Sheet infinite scroll triggered');
                      context.read<PropertyListBloc>().add(LoadMorePropertiesEvent());
                    }
                  }
                });
              }
              
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
                          BlocBuilder<PropertyListBloc, PropertyListState>(
                            builder: (context, state) {
                              int count = 0;
                              if (state is PropertyListLoaded) {
                                count = state.properties.length;
                              }
                              return Text(
                                'Show all Property "$count"',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Property list
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
                              child: Text('Error: ${state.message}'),
                            );
                          }

                          if (state is PropertyListLoaded) {
                            final properties = state.properties;
                            if (properties.isEmpty) {
                              return Center(
                                child: Text(
                                  'No properties found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: sheetScrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              itemCount: properties.length + (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Show loading indicator at the end
                                if (index == properties.length) {
                                  // Reset loading flag when new data arrives
                                  _isLoadingMore = false;
                                  
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

                          return const SizedBox.shrink();
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


  Widget _buildResultCard(Property property) {
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
    return GestureDetector(
      onTap: () {
        context.push('/maps-property/detail', extra: propertyMap);
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
                      _buildTag(property.type, 0xFF6366F1),
                      _buildTag(property.status, 0xFF10B981),
                      _buildTag('IDR ${property.price.toStringAsFixed(0)}', 0xFFF59E0B),
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
              child: const Icon(
                Icons.bookmark_outline,
                color: Color(0xFF6B7280),
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
