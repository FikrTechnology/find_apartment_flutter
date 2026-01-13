part of 'property_bloc.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class AddPropertyEvent extends PropertyEvent {
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

  const AddPropertyEvent({
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

  @override
  List<Object?> get props => [
    propertyName,
    price,
    description,
    fullAddress,
    imageBase64,
    imageName,
    type,
    status,
    buildingArea,
    landArea,
  ];
}

class ResetPropertyFormEvent extends PropertyEvent {
  const ResetPropertyFormEvent();
}
