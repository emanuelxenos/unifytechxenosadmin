// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredProductsHash() => r'6a8abd82e33d7758d6e9e2da58effa66a5dfba6e';

/// See also [filteredProducts].
@ProviderFor(filteredProducts)
final filteredProductsProvider = AutoDisposeProvider<List<Produto>>.internal(
  filteredProducts,
  name: r'filteredProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductsRef = AutoDisposeProviderRef<List<Produto>>;
String _$productsHash() => r'f1fb2c7c4a9a6e5f81b6e9f1348eafb6116cfa0e';

/// See also [Products].
@ProviderFor(Products)
final productsProvider =
    AutoDisposeAsyncNotifierProvider<Products, List<Produto>>.internal(
      Products.new,
      name: r'productsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Products = AutoDisposeAsyncNotifier<List<Produto>>;
String _$productSearchHash() => r'880d76621144a8c52e5e734f8615fb532e8d12f8';

/// See also [ProductSearch].
@ProviderFor(ProductSearch)
final productSearchProvider =
    AutoDisposeNotifierProvider<ProductSearch, String>.internal(
      ProductSearch.new,
      name: r'productSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
