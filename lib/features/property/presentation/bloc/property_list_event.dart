part of 'property_list_bloc.dart';

abstract class PropertyListEvent extends Equatable {
  const PropertyListEvent();

  @override
  List<Object?> get props => [];
}

class FetchPropertiesEvent extends PropertyListEvent {
  final String? search;
  final String? type;
  final String? status; // 'new' atau 'second'
  final int? priceMin;
  final int? priceMax;
  final String? viewMode; // 'simple' atau 'full'
  final int page;
  final int perPage;

  const FetchPropertiesEvent({
    this.search,
    this.type,
    this.status,
    this.priceMin,
    this.priceMax,
    this.viewMode = 'full',
    this.page = 1,
    this.perPage = 12,
  });

  @override
  List<Object?> get props => [
    search,
    type,
    status,
    priceMin,
    priceMax,
    viewMode,
    page,
    perPage,
  ];
}

class RefreshPropertiesEvent extends PropertyListEvent {
  const RefreshPropertiesEvent();
}

class LoadMorePropertiesEvent extends PropertyListEvent {
  const LoadMorePropertiesEvent();
}

class SearchPropertiesEvent extends PropertyListEvent {
  final String? search;
  final List<int>? ids; // Dari cluster map
  final String? type;
  final String? status;
  final int? priceMin;
  final int? priceMax;
  final String? viewMode;

  const SearchPropertiesEvent({
    this.search,
    this.ids,
    this.type,
    this.status,
    this.priceMin,
    this.priceMax,
    this.viewMode = 'full',
  });

  @override
  List<Object?> get props => [
    search,
    ids,
    type,
    status,
    priceMin,
    priceMax,
    viewMode,
  ];
}

class FetchLocationClusterEvent extends PropertyListEvent {
  final List<MapBound> bounds;
  final int? limit;

  const FetchLocationClusterEvent({
    required this.bounds,
    this.limit = 500,
  });

  @override
  List<Object?> get props => [bounds, limit];
}
