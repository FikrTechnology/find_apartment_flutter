part of 'property_list_bloc.dart';

abstract class PropertyListState extends Equatable {
  const PropertyListState();

  @override
  List<Object?> get props => [];
}

class PropertyListInitial extends PropertyListState {
  const PropertyListInitial();
}

class PropertyListLoading extends PropertyListState {
  const PropertyListLoading();
}

class PropertyListLoaded extends PropertyListState {
  final List<Property> properties;
  final PaginationMeta? pagination;
  final bool hasMore;
  final int currentPage;

  const PropertyListLoaded({
    required this.properties,
    this.pagination,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [properties, pagination, hasMore, currentPage];
}

class PropertyListError extends PropertyListState {
  final String message;

  const PropertyListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationClusterLoaded extends PropertyListState {
  final List<int> propertyIds;

  const LocationClusterLoaded({required this.propertyIds});

  @override
  List<Object?> get props => [propertyIds];
}

class LocationClusterLoading extends PropertyListState {
  const LocationClusterLoading();
}

class LocationClusterError extends PropertyListState {
  final String message;

  const LocationClusterError({required this.message});

  @override
  List<Object?> get props => [message];
}
