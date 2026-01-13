class PropertyListRequest {
  final String? search;
  final String? viewMode; // 'simple' atau 'full'
  final String? type; // rumah, apartemen, dll
  final String? status; // 'new' atau 'second'
  final int? priceMin;
  final int? priceMax;
  final int? perPage;
  final List<int>? ids;

  PropertyListRequest({
    this.search,
    this.viewMode = 'full',
    this.type,
    this.status,
    this.priceMin,
    this.priceMax,
    this.perPage, // Don't set default - let API decide
    this.ids,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (search != null && search!.isNotEmpty) {
      params['search'] = search;
    }
    if (viewMode != null) {
      params['view_mode'] = viewMode;
    }
    if (type != null && type!.isNotEmpty) {
      params['type'] = type;
    }
    if (status != null && status!.isNotEmpty) {
      params['status'] = status;
    }
    if (priceMin != null) {
      params['price_min'] = priceMin;
    }
    if (priceMax != null) {
      params['price_max'] = priceMax;
    }
    if (perPage != null) {
      params['per_page'] = perPage;
    }
    if (ids != null && ids!.isNotEmpty) {
      // Support untuk ids[] array
      for (int i = 0; i < ids!.length; i++) {
        params['ids[$i]'] = ids![i];
      }
    }
    
    return params;
  }
}

class PropertyListResponse {
  final bool success;
  final String message;
  final List<Property> data;
  final PaginationMeta? pagination;

  PropertyListResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure: data.data
    List<Property> properties = [];
    
    final dataWrapper = json['data'];
    print('🔍 PropertyListResponse: dataWrapper type = ${dataWrapper.runtimeType}');
    print('🔍 PropertyListResponse: dataWrapper = $dataWrapper');
    
    if (dataWrapper is Map) {
      // API returns data.data structure
      final actualData = dataWrapper['data'];
      print('🔍 PropertyListResponse: Found nested data.data - ${(actualData as List?)?.length ?? 0} items');
      
      if (actualData is List) {
        properties = actualData
            .map((item) => Property.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (dataWrapper is List) {
      // Standard array response
      print('🔍 PropertyListResponse: Found direct data array - ${dataWrapper.length} items');
      properties = dataWrapper
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    print('🔍 PropertyListResponse: Final properties count = ${properties.length}');
    
    return PropertyListResponse(
      success: (json['meta']?['code'] ?? 0) == 200,
      message: json['meta']?['message'] ?? 'Unknown error',
      data: properties,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class Property {
  final int id;
  final String type; // rumah, apartemen, dll
  final String status; // new, second
  final String name;
  final String description;
  final String address;
  final int price;
  final String? imageUrl;
  final int? buildingArea; // LB
  final int? landArea; // LT
  final String? postedAt;
  final bool? isBookmarked;

  Property({
    required this.id,
    required this.type,
    required this.status,
    required this.name,
    required this.description,
    required this.address,
    required this.price,
    this.imageUrl,
    this.buildingArea,
    this.landArea,
    this.postedAt,
    this.isBookmarked = false,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    // Parse price - can be string like "2990372362.00" or int
    int parsedPrice = 0;
    if (json['price'] is String) {
      final priceStr = json['price'].toString();
      // Remove decimal part if exists
      final priceDouble = double.tryParse(priceStr) ?? 0.0;
      parsedPrice = priceDouble.toInt();
    } else if (json['price'] is num) {
      parsedPrice = (json['price'] as num).toInt();
    }
    
    print('🔍 Property.fromJson: price raw=${json['price']}, parsed=$parsedPrice');
    
    return Property(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? 'second',
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      price: parsedPrice,
      imageUrl: json['image_url'] ?? json['image'],
      buildingArea: json['building_area'] ?? json['lb'],
      landArea: json['land_area'] ?? json['lt'],
      postedAt: json['posted_at'] ?? json['postTime'] ?? json['created_at'],
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'name': name,
      'description': description,
      'address': address,
      'price': price,
      'image_url': imageUrl,
      'building_area': buildingArea,
      'land_area': landArea,
      'posted_at': postedAt,
      'is_bookmarked': isBookmarked,
    };
  }
}

class PaginationMeta {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final bool hasMore;

  PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    // API response has has_more_pages instead of calculating
    final hasMore = json['has_more_pages'] ?? false;
    
    print('🔍 PaginationMeta: per_page=${json['per_page']}, has_more_pages=$hasMore');
    
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 12,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      hasMore: hasMore,
    );
  }
}
