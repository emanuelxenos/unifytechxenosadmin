// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lowStockHash() => r'0eab20714c0c96a20a4d3e1e331f697025fc0896';

/// See also [LowStock].
@ProviderFor(LowStock)
final lowStockProvider =
    AutoDisposeAsyncNotifierProvider<
      LowStock,
      List<EstoqueBaixoResponse>
    >.internal(
      LowStock.new,
      name: r'lowStockProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lowStockHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LowStock = AutoDisposeAsyncNotifier<List<EstoqueBaixoResponse>>;
String _$stockActionsHash() => r'2f2ff73efc49540b4a913f15fbb55e1740e3f115';

/// See also [StockActions].
@ProviderFor(StockActions)
final stockActionsProvider =
    AutoDisposeNotifierProvider<StockActions, bool>.internal(
      StockActions.new,
      name: r'stockActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stockActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StockActions = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
