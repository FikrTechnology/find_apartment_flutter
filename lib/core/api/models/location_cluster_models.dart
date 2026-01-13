import 'property_list_models.dart';

// ============================================================================
// LOCATION CLUSTER (POST) - Server-side clustering for map optimization
// ============================================================================

class MapBounds {
  final double swLatitude;
  final double swLongitude;
  final double neLatitude;
  final double neLongitude;

  MapBounds({
    required this.swLatitude,
    required this.swLongitude,
    required this.neLatitude,
    required this.neLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'sw_latitude': swLatitude,
      'sw_longitude': swLongitude,
      'ne_latitude': neLatitude,
      'ne_longitude': neLongitude,
    };
  }
}

class LocationClusterRequest {
  final List<MapBounds> bounds;
  final int limit;

  LocationClusterRequest({
    required this.bounds,
    this.limit = 500,
  });

  Map<String, dynamic> toJson() {
    return {
      'bounds': bounds.map((b) => b.toJson()).toList(),
      'limit': limit,
    };
  }
}

class LocationClusterResponse {
  final bool success;
  final String message;
  final List<int> propertyIds;

  LocationClusterResponse({
    required this.success,
    required this.message,
    required this.propertyIds,
  });

  factory LocationClusterResponse.fromJson(Map<String, dynamic> json) {
    List<int> ids = [];
    
    // Response data is directly a list of IDs
    if (json['data'] is List) {
      ids = List<int>.from(json['data'] as List);
    }
    
    return LocationClusterResponse(
      success: json['meta']?['code'] == 200,
      message: json['meta']?['message'] ?? 'Unknown error',
      propertyIds: ids,
    );
  }
}

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
    List<Property> properties = [];
    PaginationMeta? pagination;

    // Handle nested data structure: {data: {data: [...], pagination: {...}}}
    if (json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      
      // Get properties from nested data.data
      if (dataMap['data'] is List) {
        properties = (dataMap['data'] as List)
            .map((item) => Property.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Get pagination from nested data.pagination
      if (dataMap['pagination'] != null) {
        pagination = PaginationMeta.fromJson(dataMap['pagination']);
      }
    } 
    // Fallback: handle flat structure where data is directly a list
    else if (json['data'] is List) {
      properties = (json['data'] as List)
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
      
      if (json['pagination'] != null) {
        pagination = PaginationMeta.fromJson(json['pagination']);
      }
    }

    return PropertySearchResponse(
      success: json['meta']?['code'] == 200 || json['success'] ?? false,
      message: json['meta']?['message'] ?? json['message'] ?? 'Unknown error',
      data: properties,
      pagination: pagination,
    );
  }
}

// ============================================================================
// LOCATIONS CLUSTER (POST) - Get Property IDs by Map Clusters
// ============================================================================

// REMOVED - Use LocationClusterRequest and LocationClusterResponse above instead
