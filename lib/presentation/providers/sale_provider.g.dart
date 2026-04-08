// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesTodayHash() => r'15c570b903322baa12cad2a4a9cc143bedccb9fe';

/// See also [SalesToday].
@ProviderFor(SalesToday)
final salesTodayProvider =
    AutoDisposeAsyncNotifierProvider<SalesToday, List<Venda>>.internal(
      SalesToday.new,
      name: r'salesTodayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$salesTodayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SalesToday = AutoDisposeAsyncNotifier<List<Venda>>;
String _$saleDetailHash() => r'19372f55b0673bfeaee319396c867e83ee37cb00';

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

abstract class _$SaleDetail extends BuildlessAutoDisposeAsyncNotifier<Venda?> {
  late final int id;

  FutureOr<Venda?> build(int id);
}

/// See also [SaleDetail].
@ProviderFor(SaleDetail)
const saleDetailProvider = SaleDetailFamily();

/// See also [SaleDetail].
class SaleDetailFamily extends Family<AsyncValue<Venda?>> {
  /// See also [SaleDetail].
  const SaleDetailFamily();

  /// See also [SaleDetail].
  SaleDetailProvider call(int id) {
    return SaleDetailProvider(id);
  }

  @override
  SaleDetailProvider getProviderOverride(
    covariant SaleDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'saleDetailProvider';
}

/// See also [SaleDetail].
class SaleDetailProvider
    extends AutoDisposeAsyncNotifierProviderImpl<SaleDetail, Venda?> {
  /// See also [SaleDetail].
  SaleDetailProvider(int id)
    : this._internal(
        () => SaleDetail()..id = id,
        from: saleDetailProvider,
        name: r'saleDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$saleDetailHash,
        dependencies: SaleDetailFamily._dependencies,
        allTransitiveDependencies: SaleDetailFamily._allTransitiveDependencies,
        id: id,
      );

  SaleDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  FutureOr<Venda?> runNotifierBuild(covariant SaleDetail notifier) {
    return notifier.build(id);
  }

  @override
  Override overrideWith(SaleDetail Function() create) {
    return ProviderOverride(
      origin: this,
      override: SaleDetailProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SaleDetail, Venda?> createElement() {
    return _SaleDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaleDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SaleDetailRef on AutoDisposeAsyncNotifierProviderRef<Venda?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _SaleDetailProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<SaleDetail, Venda?>
    with SaleDetailRef {
  _SaleDetailProviderElement(super.provider);

  @override
  int get id => (origin as SaleDetailProvider).id;
}

String _$saleActionsHash() => r'988c3f637bd0b53b8042c67813a61635496454d1';

/// See also [SaleActions].
@ProviderFor(SaleActions)
final saleActionsProvider =
    AutoDisposeNotifierProvider<SaleActions, bool>.internal(
      SaleActions.new,
      name: r'saleActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$saleActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SaleActions = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
