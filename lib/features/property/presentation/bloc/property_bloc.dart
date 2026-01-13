import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/models/property_models.dart';
import '../../../../core/services/session_service.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final ApiClient _apiClient;
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  PropertyBloc({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const PropertyInitial()) {
    on<AddPropertyEvent>(_onAddProperty);
    on<ResetPropertyFormEvent>(_onResetForm);
  }

  Future<void> _onAddProperty(
    AddPropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    try {
      _logger.i('=== PROPERTY BLOC: ADD PROPERTY ===');
      _logger.i('Property Name: ${event.propertyName}');
      _logger.i('Type: ${event.type}, Status: ${event.status}');
      _logger.i('Price: ${event.price}');
      _logger.i('Building Area: ${event.buildingArea}, Land Area: ${event.landArea}');
      _logger.i('Description length: ${event.description.length}');
      _logger.i('Address: ${event.fullAddress}');
      _logger.i('Image Base64 length: ${event.imageBase64.length}');
      _logger.i('=====================================');

      // Get token from session
      final token = await _sessionService.getToken();
      _logger.d('Token retrieved: ${token != null ? 'YES (${token.length} chars)' : 'NO'}');

      if (token == null || token.isEmpty) {
        _logger.e('No token available!');
        emit(const PropertyError(message: 'Token tidak tersedia. Silakan login kembali.'));
        return;
      }

      final request = AddPropertyRequest(
        propertyName: event.propertyName,
        price: event.price,
        description: event.description,
        fullAddress: event.fullAddress,
        imageBase64: event.imageBase64,
        imageName: event.imageName,
        type: event.type,
        status: event.status,
        buildingArea: event.buildingArea,
        landArea: event.landArea,
      );

      final response = await _apiClient.addProperty(request, token: token);

      if (response.success && response.data != null) {
        _logger.i('✅ Property added successfully: ${response.data!.id}');
        emit(PropertySuccess(
          message: response.message,
          propertyId: response.data!.id,
        ));
      } else {
        _logger.w('❌ Failed to add property: ${response.message}');
        emit(PropertyError(message: response.message));
      }
    } catch (e) {
      _logger.e('❌ Error adding property: $e');
      emit(PropertyError(message: e.toString()));
    }
  }

  Future<void> _onResetForm(
    ResetPropertyFormEvent event,
    Emitter<PropertyState> emit,
  ) async {
    _logger.i('Resetting property form');
    emit(const PropertyFormReset());
    emit(const PropertyInitial());
  }
}
