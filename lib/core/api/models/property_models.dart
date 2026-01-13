class AddPropertyRequest {
  final String propertyName;
  final String price;
  final String description;
  final String fullAddress;
  final String imageBase64;
  final String imageName;

  AddPropertyRequest({
    required this.propertyName,
    required this.price,
    required this.description,
    required this.fullAddress,
    required this.imageBase64,
    required this.imageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'property_name': propertyName,
      'price': price,
      'description': description,
      'full_address': fullAddress,
      'image': imageBase64,
      'image_name': imageName,
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
    return AddPropertyResponse(
      success: json['success'] ?? false,
      message: json['meta']?['message'] ?? json['message'] ?? 'Unknown error',
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
