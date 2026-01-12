import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final List<String> locations;
  final Set<String> selectedLocations;
  final ValueChanged<Set<String>> onChanged;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedLocations,
    required this.onChanged,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  late TextEditingController _searchController;
  late List<String> _filteredLocations;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredLocations = List.from(widget.locations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = List.from(widget.locations);
      } else {
        _filteredLocations = widget.locations
            .where((location) =>
                location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleLocation(String location) {
    final newSelected = Set<String>.from(widget.selectedLocations);
    if (newSelected.contains(location)) {
      newSelected.remove(location);
    } else {
      newSelected.add(location);
    }
    widget.onChanged(newSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
            if (_isDropdownOpen) {
              _searchController.clear();
              _filteredLocations = List.from(widget.locations);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isDropdownOpen
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFE5E7EB),
                width: _isDropdownOpen ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFFAFAFA),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.selectedLocations.isEmpty
                        ? 'Select locations...'
                        : '${widget.selectedLocations.length} selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.selectedLocations.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterLocations,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _filterLocations('');
                              },
                              child: const Icon(
                                Icons.close,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: Color(0xFF6366F1), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
                // Location list
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 250,
                  ),
                  child: _filteredLocations.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No locations found',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredLocations.length,
                          itemBuilder: (context, index) {
                            final location = _filteredLocations[index];
                            final isSelected =
                                widget.selectedLocations.contains(location);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                _toggleLocation(location);
                              },
                              title: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              activeColor: const Color(0xFF6366F1),
                              checkColor: Colors.white,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              dense: true,
                            );
                          },
                        ),
                ),
                // Selected tags display
                if (widget.selectedLocations.isNotEmpty) ...[
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.selectedLocations.map((location) {
                        return Chip(
                          label: Text(location),
                          onDeleted: () {
                            _toggleLocation(location);
                          },
                          backgroundColor: const Color(0xFFEEF2FF),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 1,
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                          deleteIconColor: const Color(0xFF6366F1),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
