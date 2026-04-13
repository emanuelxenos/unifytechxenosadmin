// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supplierHistoryHash() => r'00181bbd90049f2827345bcef3c7e534161fde9b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [supplierHistory].
@ProviderFor(supplierHistory)
const supplierHistoryProvider = SupplierHistoryFamily();

/// See also [supplierHistory].
class SupplierHistoryFamily extends Family<AsyncValue<List<Compra>>> {
  /// See also [supplierHistory].
  const SupplierHistoryFamily();

  /// See also [supplierHistory].
  SupplierHistoryProvider call(int supplierId) {
    return SupplierHistoryProvider(supplierId);
  }

  @override
  SupplierHistoryProvider getProviderOverride(
    covariant SupplierHistoryProvider provider,
  ) {
    return call(provider.supplierId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supplierHistoryProvider';
}

/// See also [supplierHistory].
class SupplierHistoryProvider extends AutoDisposeFutureProvider<List<Compra>> {
  /// See also [supplierHistory].
  SupplierHistoryProvider(int supplierId)
    : this._internal(
        (ref) => supplierHistory(ref as SupplierHistoryRef, supplierId),
        from: supplierHistoryProvider,
        name: r'supplierHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supplierHistoryHash,
        dependencies: SupplierHistoryFamily._dependencies,
        allTransitiveDependencies:
            SupplierHistoryFamily._allTransitiveDependencies,
        supplierId: supplierId,
      );

  SupplierHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplierId,
  }) : super.internal();

  final int supplierId;

  @override
  Override overrideWith(
    FutureOr<List<Compra>> Function(SupplierHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupplierHistoryProvider._internal(
        (ref) => create(ref as SupplierHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplierId: supplierId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Compra>> createElement() {
    return _SupplierHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierHistoryProvider && other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplierId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupplierHistoryRef on AutoDisposeFutureProviderRef<List<Compra>> {
  /// The parameter `supplierId` of this provider.
  int get supplierId;
}

class _SupplierHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Compra>>
    with SupplierHistoryRef {
  _SupplierHistoryProviderElement(super.provider);

  @override
  int get supplierId => (origin as SupplierHistoryProvider).supplierId;
}

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
