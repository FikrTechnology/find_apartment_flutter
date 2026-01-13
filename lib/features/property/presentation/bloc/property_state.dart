part of 'property_bloc.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {
  const PropertyInitial();
}

class PropertyLoading extends PropertyState {
  const PropertyLoading();
}

class PropertySuccess extends PropertyState {
  final String message;
  final int propertyId;

  const PropertySuccess({
    required this.message,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [message, propertyId];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PropertyFormReset extends PropertyState {
  const PropertyFormReset();
}
