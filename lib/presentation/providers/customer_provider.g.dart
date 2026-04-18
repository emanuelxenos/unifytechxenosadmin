// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredCustomersHash() => r'0dc37e3b7d5405262dfddf1344f8900569b2678c';

/// See also [filteredCustomers].
@ProviderFor(filteredCustomers)
final filteredCustomersProvider = AutoDisposeProvider<List<Cliente>>.internal(
  filteredCustomers,
  name: r'filteredCustomersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredCustomersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCustomersRef = AutoDisposeProviderRef<List<Cliente>>;
String _$customersHash() => r'8e31b30eae865f9fbae200a15f3405652b0dfb4a';

/// See also [Customers].
@ProviderFor(Customers)
final customersProvider =
    AutoDisposeAsyncNotifierProvider<Customers, List<Cliente>>.internal(
      Customers.new,
      name: r'customersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Customers = AutoDisposeAsyncNotifier<List<Cliente>>;
String _$customerSearchHash() => r'098e982ba279d5aff51ff80efeabce66b09dfa10';

/// See also [CustomerSearch].
@ProviderFor(CustomerSearch)
final customerSearchProvider =
    AutoDisposeNotifierProvider<CustomerSearch, String>.internal(
      CustomerSearch.new,
      name: r'customerSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerSearch = AutoDisposeNotifier<String>;
String _$customerInactivesHash() => r'2ba566ea9711805455137ea288b50a2c5b496611';

/// See also [CustomerInactives].
@ProviderFor(CustomerInactives)
final customerInactivesProvider =
    AutoDisposeNotifierProvider<CustomerInactives, bool>.internal(
      CustomerInactives.new,
      name: r'customerInactivesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerInactivesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CustomerInactives = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
