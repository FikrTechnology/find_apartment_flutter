import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';

class SearchResultPage extends StatefulWidget {
  final String? initialQuery;

  const SearchResultPage({super.key, this.initialQuery});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredResults = [];

  // Sample data - dalam aplikasi nyata ini akan dari API
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
      'title': 'Cozy Studio Near Campus',
      'location': 'Jakarta',
      'address': 'Jl. Gatot Subroto No. 456, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 1.850.000',
      'landArea': 'LT 36 m2',
      'buildingArea': 'LB 32 m2',
      'postTime': '1 week ago',
      'isBookmarked': false,
    },
    {
      'title': 'Luxury 2BR with Pool Access',
      'location': 'Bekasi',
      'address': 'Jl. Merdeka No. 789, Bekasi Utara',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 3.750.000',
      'landArea': 'LT 50 m2',
      'buildingArea': 'LB 45 m2',
      'postTime': '1 month ago',
      'isBookmarked': false,
    },
    {
      'title': 'Spacious Family Apartment',
      'location': 'Jakarta',
      'address': 'Jl. Imam Bonjol No. 321, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 4.200.000',
      'landArea': 'LT 55 m2',
      'buildingArea': 'LB 50 m2',
      'postTime': '3 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Budget-Friendly Apartment',
      'location': 'Bandung',
      'address': 'Jl. Braga No. 654, Bandung',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 1.450.000',
      'landArea': 'LT 30 m2',
      'buildingArea': 'LB 28 m2',
      'postTime': '5 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Premium Penthouse Suite',
      'location': 'Bandung',
      'address': 'Jl. Cisangkuy No. 987, Bandung',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 5.650.000',
      'landArea': 'LT 60 m2',
      'buildingArea': 'LB 55 m2',
      'postTime': '1 week ago',
      'isBookmarked': false,
    },
    {
      'title': 'Cozy Apartment with Balcony',
      'location': 'Jakarta',
      'address': 'Jl. Senayan No. 147, Jakarta Selatan',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 2.100.000',
      'landArea': 'LT 48 m2',
      'buildingArea': 'LB 42 m2',
      'postTime': '10 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Apartment Near Business District',
      'location': 'Bekasi',
      'address': 'Jl. Harapan Indah No. 258, Bekasi Barat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 3.200.000',
      'landArea': 'LT 42 m2',
      'buildingArea': 'LB 38 m2',
      'postTime': '2 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Modern Studio Apartment',
      'location': 'Jakarta',
      'address': 'Jl. Menteng No. 159, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 1.650.000',
      'landArea': 'LT 25 m2',
      'buildingArea': 'LB 22 m2',
      'postTime': '3 weeks ago',
      'isBookmarked': false,
    },
    {
      'title': 'Elegant 3BR Apartment with Garden',
      'location': 'Bandung',
      'address': 'Jl. Riau No. 456, Bandung',
      'type': 'Apartment',
      'status': 'Second',
      'price': 'IDR 4.850.000',
      'landArea': 'LT 65 m2',
      'buildingArea': 'LB 60 m2',
      'postTime': '4 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Apartment with Modern Facilities',
      'location': 'Jakarta',
      'address': 'Jl. Diponegoro No. 789, Jakarta Pusat',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 2.750.000',
      'landArea': 'LT 40 m2',
      'buildingArea': 'LB 35 m2',
      'postTime': '6 days ago',
      'isBookmarked': false,
    },
    {
      'title': 'Furnished Apartment Ready to Move',
      'location': 'Bekasi',
      'address': 'Jl. Permata No. 321, Bekasi Selatan',
      'type': 'Apartment',
      'status': 'New',
      'price': 'IDR 2.900.000',
      'landArea': 'LT 44 m2',
      'buildingArea': 'LB 40 m2',
      'postTime': '8 days ago',
      'isBookmarked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Jika ada initial query dari route, set ke controller
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _onSearchChanged();
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredResults = [];
      } else {
        _filteredResults = _allResults
            .where((item) => item['title']!
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
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
              onPressed: () => context.go('/home'),
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
      body: _searchController.text.isEmpty
          ? Center(
              child: Text(
                'Start typing to search properties',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result header
                    if (_filteredResults.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Result from "${_searchController.text}"',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '${_filteredResults.length} Property',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No results found for "${_searchController.text}"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    if (_filteredResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Search results list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            _filteredResults.length > 6 ? 6 : _filteredResults.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Color(0xFFE5E7EB),
                          height: 1,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final result = _filteredResults[index];
                          return _buildSearchResultItem(result);
                        },
                      ),
                      if (_filteredResults.length > 6) ...[
                        const SizedBox(height: 16),
                        // See all results button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => context.go(
                                '/all-search-result?q=${_searchController.text}'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF6366F1),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'See all result',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6366F1),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        context.push('/search-result/detail', extra: item);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Image placeholder
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
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['price'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_outward,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
