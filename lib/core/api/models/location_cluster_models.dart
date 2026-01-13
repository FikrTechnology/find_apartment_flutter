import 'property_list_models.dart';

// ============================================================================
// PROPERTIES SEARCH (POST) - Support Bulk IDs & Complex Filters
// ============================================================================

class PropertySearchRequest {
  final String? search;
  final List<int>? ids; // Bulk IDs dari cluster map
  final String? viewMode; // 'simple' atau 'full'
  final String? type;
  final String? status; // 'new' atau 'second'
  final int? priceMin;
  final int? priceMax;
  final int? perPage;

  PropertySearchRequest({
    this.search,
    this.ids,
    this.viewMode = 'full',
    this.type,
    this.status,
    this.priceMin,
    this.priceMax,
    this.perPage = 20,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) {
      data['search'] = search;
    }
    if (ids != null && ids!.isNotEmpty) {
      data['ids'] = ids;
    }
    if (viewMode != null) {
      data['view_mode'] = viewMode;
    }
    if (type != null && type!.isNotEmpty) {
      data['type'] = type;
    }
    if (status != null && status!.isNotEmpty) {
      data['status'] = status;
    }
    if (priceMin != null) {
      data['price_min'] = priceMin;
    }
    if (priceMax != null) {
      data['price_max'] = priceMax;
    }
    if (perPage != null) {
      data['per_page'] = perPage;
    }
    
    return data;
  }
}

class PropertySearchResponse {
  final bool success;
  final String message;
  final List<Property> data;
  final PaginationMeta? pagination;

  PropertySearchResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory PropertySearchResponse.fromJson(Map<String, dynamic> json) {
    return PropertySearchResponse(
      success: json['success'] ?? false,
      message: json['meta']?['message'] ?? json['message'] ?? 'Unknown error',
      data: (json['data'] as List?)
              ?.map((item) => Property.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

// ============================================================================
// LOCATIONS CLUSTER (POST) - Get Property IDs by Map Clusters
// ============================================================================

class LocationClusterRequest {
  final List<MapBound> bounds;
  final int? limit;

  LocationClusterRequest({
    required this.bounds,
    this.limit = 500,
  });

  Map<String, dynamic> toJson() {
    return {
      'bounds': bounds.map((b) => b.toJson()).toList(),
      'limit': limit ?? 500,
    };
  }
}

class MapBound {
  final double swLatitude;
  final double swLongitude;
  final double neLatitude;
  final double neLongitude;

  MapBound({
    required this.swLatitude,
    required this.swLongitude,
    required this.neLatitude,
    required this.neLongitude,
  });

  factory MapBound.fromJson(Map<String, dynamic> json) {
    return MapBound(
      swLatitude: (json['sw_latitude'] as num?)?.toDouble() ?? 0.0,
      swLongitude: (json['sw_longitude'] as num?)?.toDouble() ?? 0.0,
      neLatitude: (json['ne_latitude'] as num?)?.toDouble() ?? 0.0,
      neLongitude: (json['ne_longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sw_latitude': swLatitude,
      'sw_longitude': swLongitude,
      'ne_latitude': neLatitude,
      'ne_longitude': neLongitude,
    };
  }
}

class LocationClusterResponse {
  final bool success;
  final String message;
  final List<int> propertyIds; // List of property IDs dalam cluster

  LocationClusterResponse({
    required this.success,
    required this.message,
    required this.propertyIds,
  });

  factory LocationClusterResponse.fromJson(Map<String, dynamic> json) {
    final metaCode = json['meta']?['code'];
    final success = metaCode == 200 || (json['success'] ?? false);
    
    return LocationClusterResponse(
      success: success,
      message: json['meta']?['message'] ?? json['message'] ?? 'Unknown error',
      propertyIds: (json['data'] as List?)?.map((id) {
            if (id is int) return id;
            if (id is String) return int.tryParse(id) ?? 0;
            return 0;
          }).toList() ??
          [],
    );
  }
}
