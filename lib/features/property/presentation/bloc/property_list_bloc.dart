import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/models/property_list_models.dart';
import '../../../../core/api/models/location_cluster_models.dart';
import '../../../../core/services/session_service.dart';

part 'property_list_event.dart';
part 'property_list_state.dart';

class PropertyListBloc extends Bloc<PropertyListEvent, PropertyListState> {
  final ApiClient _apiClient;
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  List<Property> _allProperties = [];
  PaginationMeta? _pagination;
  int _currentPage = 1;

  PropertyListBloc({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const PropertyListInitial()) {
    on<FetchPropertiesEvent>(_onFetchProperties);
    on<RefreshPropertiesEvent>(_onRefreshProperties);
    on<LoadMorePropertiesEvent>(_onLoadMoreProperties);
    on<SearchPropertiesEvent>(_onSearchProperties);
    on<FetchLocationClusterEvent>(_onFetchLocationCluster);
  }

  Future<void> _onFetchProperties(
    FetchPropertiesEvent event,
    Emitter<PropertyListState> emit,
  ) async {
    emit(const PropertyListLoading());

    try {
      _logger.i('Fetching properties: search=${event.search}, type=${event.type}');
      print('📍 PropertyListBloc: _onFetchProperties called');

      // Get token from session
      final token = await _sessionService.getToken();
      print('📍 PropertyListBloc: Token retrieved - ${token != null ? 'YES (${token.length} chars)' : 'NO'}');
      
      if (token == null || token.isEmpty) {
        print('⚠️  PropertyListBloc: WARNING - Token is null or empty!');
      } else {
        print('📍 PropertyListBloc: Token first 30 chars: ${token.substring(0, 30)}...');
      }

      _logger.d('Using token for API request: ${token != null}');

      final request = PropertyListRequest(
        search: event.search,
        type: event.type,
        status: event.status,
        priceMin: event.priceMin,
        priceMax: event.priceMax,
        viewMode: event.viewMode,
        perPage: event.perPage,
      );

      final response = await _apiClient.getProperties(request, token: token);

      if (response.success) {
        _allProperties = response.data;
        _pagination = response.pagination;
        _currentPage = 1;

        print('📍 PropertyListBloc: Response SUCCESS - ${response.data.length} items found');

        _logger.i(
          'Properties fetched: ${response.data.length} items, '
          'page ${_pagination?.currentPage}/${_pagination?.lastPage}',
        );

        emit(PropertyListLoaded(
          properties: _allProperties,
          pagination: _pagination,
          hasMore: _pagination?.hasMore ?? false,
          currentPage: _currentPage,
        ));
        
        print('📍 PropertyListBloc: EMITTED PropertyListLoaded with ${_allProperties.length} items');
      } else {
        print('📍 PropertyListBloc: Response NOT SUCCESS - message=${response.message}');
        _logger.w('Failed to fetch properties: ${response.message}');
        emit(PropertyListError(message: response.message));
      }
    } catch (e) {
      _logger.e('Error fetching properties: $e');
      emit(PropertyListError(message: e.toString()));
    }
  }

  Future<void> _onRefreshProperties(
    RefreshPropertiesEvent event,
    Emitter<PropertyListState> emit,
  ) async {
    _logger.i('Refreshing properties');
    _currentPage = 1;
    _allProperties = [];

    if (state is PropertyListLoaded) {
      final currentState = state as PropertyListLoaded;
      emit(const PropertyListLoading());

      try {
        final token = await _sessionService.getToken();
        // Use perPage from current pagination if available, otherwise let API decide
        final request = PropertyListRequest(
          perPage: currentState.pagination?.perPage,
        );

        final response = await _apiClient.getProperties(request, token: token);

        if (response.success) {
          _allProperties = response.data;
          _pagination = response.pagination;

          emit(PropertyListLoaded(
            properties: _allProperties,
            pagination: _pagination,
            hasMore: _pagination?.hasMore ?? false,
            currentPage: 1,
          ));
        } else {
          emit(PropertyListError(message: response.message));
        }
      } catch (e) {
        _logger.e('Error refreshing properties: $e');
        emit(PropertyListError(message: e.toString()));
      }
    }
  }

  Future<void> _onLoadMoreProperties(
    LoadMorePropertiesEvent event,
    Emitter<PropertyListState> emit,
  ) async {
    _logger.i('Loading more properties');

    if (state is PropertyListLoaded) {
      final currentState = state as PropertyListLoaded;

      if (!currentState.hasMore) {
        _logger.w('No more properties to load');
        return;
      }

      try {
        final nextPage = (_pagination?.currentPage ?? 1) + 1;
        final token = await _sessionService.getToken();

        // Use perPage from pagination if available, otherwise null (let API decide)
        int? perPage;
        if (_pagination?.perPage != null && _pagination!.perPage > 0) {
          perPage = _pagination!.perPage;
        }

        final request = PropertyListRequest(
          perPage: perPage,
        );

        final response = await _apiClient.getProperties(request, token: token);

        if (response.success) {
          _allProperties.addAll(response.data);
          _pagination = response.pagination;
          _currentPage = nextPage;

          _logger.i('Loaded more properties: total ${_allProperties.length}');

          emit(PropertyListLoaded(
            properties: _allProperties,
            pagination: _pagination,
            hasMore: _pagination?.hasMore ?? false,
            currentPage: _currentPage,
          ));
        } else {
          emit(PropertyListError(message: response.message));
        }
      } catch (e) {
        _logger.e('Error loading more properties: $e');
        emit(PropertyListError(message: e.toString()));
      }
    }
  }

  Future<void> _onSearchProperties(
    SearchPropertiesEvent event,
    Emitter<PropertyListState> emit,
  ) async {
    emit(const PropertyListLoading());

    try {
      _logger.i('Searching properties with bulk IDs and filters');

      final token = await _sessionService.getToken();
      _logger.d('Using token for search: ${token != null}');

      final request = PropertySearchRequest(
        search: event.search,
        ids: event.ids,
        type: event.type,
        status: event.status,
        priceMin: event.priceMin,
        priceMax: event.priceMax,
        viewMode: event.viewMode,
      );

      final response = await _apiClient.searchProperties(request, token: token);

      if (response.success) {
        _allProperties = response.data;
        _pagination = response.pagination;
        _currentPage = 1;

        _logger.i(
          'Search completed: ${response.data.length} properties found',
        );

        emit(PropertyListLoaded(
          properties: _allProperties,
          pagination: _pagination,
          hasMore: _pagination?.hasMore ?? false,
          currentPage: _currentPage,
        ));
      } else {
        _logger.w('Search failed: ${response.message}');
        emit(PropertyListError(message: response.message));
      }
    } catch (e) {
      _logger.e('Error searching properties: $e');
      emit(PropertyListError(message: e.toString()));
    }
  }

  Future<void> _onFetchLocationCluster(
    FetchLocationClusterEvent event,
    Emitter<PropertyListState> emit,
  ) async {
    emit(const LocationClusterLoading());

    try {
      _logger.i('Fetching location cluster for ${event.bounds.length} bounds');

      final token = await _sessionService.getToken();
      _logger.d('Using token for cluster: ${token != null}');

      final request = LocationClusterRequest(
        bounds: event.bounds,
        limit: event.limit ?? 500,
      );

      final response = await _apiClient.getLocationCluster(
        request,
        token: token,
      );

      if (response.success) {
        _logger.i('Location cluster fetched: ${response.propertyIds.length} IDs');

        emit(LocationClusterLoaded(propertyIds: response.propertyIds));
      } else {
        _logger.w('Cluster fetch failed: ${response.message}');
        emit(LocationClusterError(message: response.message));
      }
    } catch (e) {
      _logger.e('Error fetching location cluster: $e');
      emit(LocationClusterError(message: e.toString()));
    }
  }
}
