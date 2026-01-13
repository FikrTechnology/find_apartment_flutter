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
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e('API Error: ${e.type} - ${e.message}');
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
      }
      
      final requestData = request.toJson();
      
      final response = await _dio.post(
        '/properties',
        data: requestData,
        options: Options(headers: headers),
      );
      
      _logger.i('Property added successfully: ${request.propertyName}');
      return AddPropertyResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Add property error: ${_handleDioException(e)}');
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
      
      // Set authorization header if token provided
      final headers = <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _logger.d('Using Bearer token for authentication');
      }

      final response = await _dio.get(
        '/properties',
        queryParameters: request.toQueryParams(),
        options: Options(headers: headers),
      );
      
      _logger.i('Properties fetched successfully');
      return PropertyListResponse.fromJson(response.data);
    } on DioException catch (e) {
      _logger.e('Get properties error: ${_handleDioException(e)}');
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
