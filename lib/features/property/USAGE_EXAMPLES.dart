/// USAGE EXAMPLES FOR NEW ENDPOINTS
/// ============================================================================

// Import required
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'lib/features/property/presentation/bloc/property_list_bloc.dart';
// import 'lib/core/api/models/location_cluster_models.dart';

// ============================================================================
// 1. GET /properties - Simple property list with filters
// ============================================================================
void exampleGetProperties() {
  // Contoh: Fetch semua properti dengan default 12 per page
  // context.read<PropertyListBloc>().add(
  //   const FetchPropertiesEvent()
  // );

  // Contoh: Fetch dengan filter
  // context.read<PropertyListBloc>().add(
  //   FetchPropertiesEvent(
  //     search: 'Minimalis',
  //     type: 'rumah',
  //     status: 'new',
  //     priceMin: 500000000,
  //     priceMax: 2000000000,
  //     viewMode: 'full',
  //     perPage: 24,
  //   )
  // );

  // Contoh: View mode simple (lighter data)
  // context.read<PropertyListBloc>().add(
  //   FetchPropertiesEvent(
  //     viewMode: 'simple',
  //     perPage: 50,
  //   )
  // );
}

// ============================================================================
// 2. POST /properties/search - Bulk search dengan IDs dari map cluster
// ============================================================================
void exampleSearchProperties() {
  // Contoh: Setelah user klik di map cluster, dapat list ID properti
  // Lalu gunakan untuk pencarian bulk
  
  // final propertyIds = [1, 2, 5, 10, 50]; // Dari location cluster response
  
  // context.read<PropertyListBloc>().add(
  //   SearchPropertiesEvent(
  //     ids: propertyIds,        // Bulk IDs dari cluster
  //     type: 'rumah',
  //     status: 'new',
  //     priceMin: 1000000000,
  //     priceMax: 3000000000,
  //     viewMode: 'full',
  //   )
  // );

  // Contoh: Combine search text + bulk IDs
  // context.read<PropertyListBloc>().add(
  //   SearchPropertiesEvent(
  //     search: 'Asri',
  //     ids: [1, 2, 5, 10, 50],
  //     viewMode: 'simple',
  //   )
  // );
}

// ============================================================================
// 3. POST /locations/cluster - Get property IDs by map boundaries
// ============================================================================
void exampleFetchLocationCluster() {
  // Contoh: User zoom/pan di map, endpoint ini mengirim bounding box
  // dan dapat kembali list ID properti dalam area tersebut
  
  // final bounds = [
  //   MapBound(
  //     swLatitude: -6.250477,
  //     swLongitude: 106.797414,
  //     neLatitude: -6.106749,
  //     neLongitude: 106.910196,
  //   ),
  // ];
  
  // context.read<PropertyListBloc>().add(
  //   FetchLocationClusterEvent(
  //     bounds: bounds,
  //     limit: 500, // Max properties to return
  //   )
  // );

  // Contoh: Multiple bounds (untuk area besar)
  // final bounds = [
  //   MapBound(
  //     swLatitude: -6.250477,
  //     swLongitude: 106.797414,
  //     neLatitude: -6.106749,
  //     neLongitude: 106.910196,
  //   ),
  //   MapBound(
  //     swLatitude: -6.300000,
  //     swLongitude: 106.850000,
  //     neLatitude: -6.200000,
  //     neLongitude: 106.950000,
  //   ),
  // ];
  
  // context.read<PropertyListBloc>().add(
  //   FetchLocationClusterEvent(
  //     bounds: bounds,
  //     limit: 1000,
  //   )
  // );
}

// ============================================================================
// 4. PAGINATION & LOAD MORE
// ============================================================================
void examplePagination() {
  // Refresh data
  // context.read<PropertyListBloc>().add(
  //   const RefreshPropertiesEvent()
  // );

  // Load more (untuk pagination)
  // context.read<PropertyListBloc>().add(
  //   const LoadMorePropertiesEvent()
  // );
}

// ============================================================================
// 5. HANDLING STATES IN UI
// ============================================================================
void exampleStateHandling() {
  // return BlocBuilder<PropertyListBloc, PropertyListState>(
  //   builder: (context, state) {
  //     if (state is PropertyListLoading) {
  //       return const Center(child: CircularProgressIndicator());
  //     } else if (state is PropertyListLoaded) {
  //       return ListView.builder(
  //         itemCount: state.properties.length,
  //         itemBuilder: (context, index) {
  //           final property = state.properties[index];
  //           return PropertyCard(property: property);
  //         },
  //       );
  //     } else if (state is PropertyListError) {
  //       return Center(child: Text('Error: ${state.message}'));
  //     } else if (state is LocationClusterLoaded) {
  //       // Handle map cluster result
  //       // state.propertyIds contains list of property IDs
  //       return Text('Found ${state.propertyIds.length} properties');
  //     } else if (state is LocationClusterLoading) {
  //       return const Center(child: CircularProgressIndicator());
  //     } else if (state is LocationClusterError) {
  //       return Center(child: Text('Error: ${state.message}'));
  //     }
  //     return const SizedBox.shrink();
  //   },
  // );
}

// ============================================================================
// 6. COMPLETE WORKFLOW EXAMPLE
// ============================================================================
void exampleCompleteWorkflow() {
  // Workflow: User zoom ke area di map → fetch cluster → search properties
  
  // Step 1: User melihat map dan zoom ke area tertentu
  // final mapBounds = MapBound(
  //   swLatitude: -6.250477,
  //   swLongitude: 106.797414,
  //   neLatitude: -6.106749,
  //   neLongitude: 106.910196,
  // );
  
  // Step 2: Fetch property IDs dari cluster
  // context.read<PropertyListBloc>().add(
  //   FetchLocationClusterEvent(bounds: [mapBounds])
  // );
  
  // Step 3: State becomes LocationClusterLoaded dengan list property IDs
  // Step 4: Gunakan IDs tersebut untuk search properties
  // context.read<PropertyListBloc>().add(
  //   SearchPropertiesEvent(
  //     ids: propertyIds, // dari LocationClusterLoaded
  //     type: 'rumah',
  //     priceMin: 500000000,
  //   )
  // );
  
  // Step 5: State becomes PropertyListLoaded dengan actual property data
}
