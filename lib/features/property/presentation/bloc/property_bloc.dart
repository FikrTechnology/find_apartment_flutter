import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/models/property_models.dart';

part 'property_event.dart';
part 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final ApiClient _apiClient;
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
      _logger.i('Adding property: ${event.propertyName}');

      final request = AddPropertyRequest(
        propertyName: event.propertyName,
        price: event.price,
        description: event.description,
        fullAddress: event.fullAddress,
        imageBase64: event.imageBase64,
        imageName: event.imageName,
      );

      final response = await _apiClient.addProperty(request);

      if (response.success && response.data != null) {
        _logger.i('Property added successfully: ${response.data!.id}');
        emit(PropertySuccess(
          message: response.message,
          propertyId: response.data!.id,
        ));
      } else {
        _logger.w('Failed to add property: ${response.message}');
        emit(PropertyError(message: response.message));
      }
    } catch (e) {
      _logger.e('Error adding property: $e');
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
