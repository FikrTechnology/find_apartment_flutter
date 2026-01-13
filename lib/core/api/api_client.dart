import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'models/auth_models.dart';
import 'models/login_models.dart';
import 'models/property_models.dart';
import 'models/property_list_models.dart';
import 'models/location_cluster_models.dart';

class ApiClient {
  static const String baseUrl = 'https://api-test.linkedinindonesia.com/api';
  
  late Dio _dio;
  final Logger _logger = Logger();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    _logger.i('ApiClient initialized with baseUrl: $baseUrl');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e('Error: ${e.type} - ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      _logger.i('Registering user: ${request.email}');
      final response = await _dio.post(
        '/register',
        data: request.toJson(),
      );
      _logger.i('Register success for: ${request.email}');
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Register error: ${_handleDioException(e)}');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during register: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      _logger.i('Logging in user: ${request.email}');
      final response = await _dio.post(
        '/login',
        data: request.toJson(),
      );
      _logger.i('Login success for: ${request.email}');
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Login error: ${_handleDioException(e)}');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during login: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<AddPropertyResponse> addProperty(
    AddPropertyRequest request, {
    String? token,
  }) async {
    try {
      _logger.i('Adding property: ${request.propertyName}');
      
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('Using Bearer token for add property');
      }
      
      final requestData = request.toJson();
      
      // Log request details
      _logger.i('=== ADD PROPERTY REQUEST ===');
      _logger.i('Type: ${requestData['type']}');
      _logger.i('Status: ${requestData['status']}');
      _logger.i('Name: ${requestData['name']}');
      _logger.i('Description: ${requestData['description']}');
      _logger.i('Address: ${requestData['address']}');
      _logger.i('Price: ${requestData['price']} (type: ${requestData['price'].runtimeType})');
      _logger.i('Building Area: ${requestData['building_area']} (type: ${requestData['building_area'].runtimeType})');
      _logger.i('Land Area: ${requestData['land_area']} (type: ${requestData['land_area'].runtimeType})');
      _logger.i('Image first 100 chars: ${(requestData['image'] as String).substring(0, 100)}');
      _logger.i('Image length: ${(requestData['image'] as String).length} chars');
      _logger.i('========================');
      
      final response = await _dio.post(
        '/properties',
        data: requestData,
        options: Options(headers: headers),
      );
      
      _logger.i('Property added successfully: ${request.propertyName}');
      _logger.i('Response: ${response.data}');
      return AddPropertyResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('=== ADD PROPERTY ERROR ===');
      _logger.e('DioException Type: ${e.type}');
      _logger.e('Status Code: ${e.response?.statusCode}');
      _logger.e('Response Data: ${e.response?.data}');
      _logger.e('Error Message: ${e.message}');
      _logger.e('========================');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during add property: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<PropertyListResponse> getProperties(
    PropertyListRequest request, {
    String? token,
  }) async {
    try {
      _logger.i('Fetching properties with filters');
      print('🔐 API: getProperties called');
      print('🔐 API: Token provided: ${token != null ? 'YES (${token.length} chars)' : 'NO'}');
      
      // Set authorization header if token provided
      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 API: Authorization header SET: Bearer ${token.substring(0, 20)}...');
        _logger.d('Using Bearer token for authentication');
      } else {
        print('⚠️  API: WARNING - No token provided for getProperties!');
      }

      print('🔐 API: Final headers: $headers');
      
      final response = await _dio.get(
        '/properties',
        queryParameters: request.toQueryParams(),
        options: Options(headers: headers),
      );
      
      _logger.i('Properties fetched successfully');
      return PropertyListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Get properties error: ${_handleDioException(e)}');
      print('❌ API Error: ${e.type} - ${e.message}');
      print('❌ API Response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during get properties: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<PropertySearchResponse> searchProperties(
    PropertySearchRequest request, {
    String? token,
  }) async {
    try {
      _logger.i('Searching properties with bulk IDs and filters');

      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('Using Bearer token for authentication');
      }

      final response = await _dio.post(
        '/properties/search',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      _logger.i('Property search completed successfully');
      return PropertySearchResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Search properties error: ${_handleDioException(e)}');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during search properties: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<LocationClusterResponse> getLocationCluster(
    LocationClusterRequest request, {
    String? token,
  }) async {
    try {
      _logger.i('Fetching location cluster for ${request.bounds.length} bounds');

      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('Using Bearer token for authentication');
      }

      final response = await _dio.post(
        '/locations/cluster',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      _logger.i('Location cluster fetched successfully');
      return LocationClusterResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Get location cluster error: ${_handleDioException(e)}');
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error during get location cluster: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (e.response != null && e.response!.data is Map) {
          final data = e.response!.data as Map;
          if (data['meta'] != null && data['meta']['message'] != null) {
            return data['meta']['message'].toString();
          }
        }
        return 'Error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return 'Network error. Please check your connection.';
    }
  }
}
