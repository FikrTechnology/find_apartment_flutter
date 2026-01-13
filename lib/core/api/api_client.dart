import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'models/auth_models.dart';
import 'models/login_models.dart';
import 'models/property_models.dart';

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

  Future<AddPropertyResponse> addProperty(AddPropertyRequest request) async {
    try {
      _logger.i('Adding property: ${request.propertyName}');
      final response = await _dio.post(
        '/properties/add',
        data: request.toJson(),
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
