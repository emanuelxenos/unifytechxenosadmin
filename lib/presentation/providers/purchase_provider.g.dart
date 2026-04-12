// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$purchasesHash() => r'352df412d9855800aad66e38d05d26165e742ca3';

/// See also [Purchases].
@ProviderFor(Purchases)
final purchasesProvider =
    AutoDisposeAsyncNotifierProvider<Purchases, List<Compra>>.internal(
      Purchases.new,
      name: r'purchasesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$purchasesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Purchases = AutoDisposeAsyncNotifier<List<Compra>>;
String _$purchaseActionsHash() => r'7bef7094363f051a8740a357d6ba34298f1940ad';

/// See also [PurchaseActions].
@ProviderFor(PurchaseActions)
final purchaseActionsProvider =
    AutoDisposeNotifierProvider<PurchaseActions, bool>.internal(
      PurchaseActions.new,
      name: r'purchaseActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$purchaseActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PurchaseActions = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
