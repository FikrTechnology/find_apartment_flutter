class AddPropertyRequest {
  final String propertyName;
  final String price;
  final String description;
  final String fullAddress;
  final String imageBase64;
  final String imageName;
  final String type;
  final String status;
  final String buildingArea;
  final String landArea;

  AddPropertyRequest({
    required this.propertyName,
    required this.price,
    required this.description,
    required this.fullAddress,
    required this.imageBase64,
    required this.imageName,
    required this.type,
    required this.status,
    required this.buildingArea,
    required this.landArea,
  });

  Map<String, dynamic> toJson() {
    // Determine MIME type based on image name
    String mimeType = 'image/jpeg';
    if (imageName.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (imageName.toLowerCase().endsWith('.gif')) {
      mimeType = 'image/gif';
    } else if (imageName.toLowerCase().endsWith('.webp')) {
      mimeType = 'image/webp';
    }
    
    // Format image with data URI prefix
    final imageDataUri = 'data:$mimeType;base64,$imageBase64';
    
    return {
      'type': type,
      'status': status,
      'name': propertyName,
      'description': description,
      'address': fullAddress,
      'price': int.parse(price),
      'image': imageDataUri,
      'building_area': int.parse(buildingArea),
      'land_area': int.parse(landArea),
    };
  }
}

class AddPropertyResponse {
  final bool success;
  final String message;
  final PropertyData? data;

  AddPropertyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AddPropertyResponse.fromJson(Map<String, dynamic> json) {
    // Try to extract success status - different backends use different formats
    bool success = false;
    String message = 'Unknown error';
    
    // Check for meta.code == 200
    if (json['meta'] is Map) {
      final metaCode = json['meta']['code'];
      success = metaCode == 200 || metaCode == '200';
      message = json['meta']?['message'] ?? message;
    }
    
    // Fallback: check for direct 'success' field
    if (!success && json.containsKey('success')) {
      success = json['success'] == true || json['success'] == 'true';
      message = json['message'] ?? message;
    }
    
    // Fallback: if status is 'success' or 'ok'
    if (!success) {
      final status = json['status']?.toString().toLowerCase();
      success = status == 'success' || status == 'ok';
      if (success) {
        message = json['message'] ?? 'Property added successfully';
      }
    }

    return AddPropertyResponse(
      success: success,
      message: message,
      data: json['data'] != null ? PropertyData.fromJson(json['data']) : null,
    );
  }
}

class PropertyData {
  final int id;
  final String propertyName;
  final String price;
  final String description;
  final String fullAddress;
  final String? imageUrl;

  PropertyData({
    required this.id,
    required this.propertyName,
    required this.price,
    required this.description,
    required this.fullAddress,
    this.imageUrl,
  });

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    return PropertyData(
      id: json['id'] ?? 0,
      propertyName: json['property_name'] ?? '',
      price: json['price'] ?? '',
      description: json['description'] ?? '',
      fullAddress: json['full_address'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
