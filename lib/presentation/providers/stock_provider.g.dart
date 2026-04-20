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
String _$stockMovementsHash() => r'3c78466535a6f272f91783c5f4639cd8c5664fd4';

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

abstract class _$StockMovements
    extends BuildlessAutoDisposeAsyncNotifier<List<EstoqueMovimentacao>> {
  late final int? produtoId;
  late final DateTime? inicio;
  late final DateTime? fim;

  FutureOr<List<EstoqueMovimentacao>> build({
    int? produtoId,
    DateTime? inicio,
    DateTime? fim,
  });
}

/// See also [StockMovements].
@ProviderFor(StockMovements)
const stockMovementsProvider = StockMovementsFamily();

/// See also [StockMovements].
class StockMovementsFamily
    extends Family<AsyncValue<List<EstoqueMovimentacao>>> {
  /// See also [StockMovements].
  const StockMovementsFamily();

  /// See also [StockMovements].
  StockMovementsProvider call({
    int? produtoId,
    DateTime? inicio,
    DateTime? fim,
  }) {
    return StockMovementsProvider(
      produtoId: produtoId,
      inicio: inicio,
      fim: fim,
    );
  }

  @override
  StockMovementsProvider getProviderOverride(
    covariant StockMovementsProvider provider,
  ) {
    return call(
      produtoId: provider.produtoId,
      inicio: provider.inicio,
      fim: provider.fim,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stockMovementsProvider';
}

/// See also [StockMovements].
class StockMovementsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StockMovements,
          List<EstoqueMovimentacao>
        > {
  /// See also [StockMovements].
  StockMovementsProvider({int? produtoId, DateTime? inicio, DateTime? fim})
    : this._internal(
        () => StockMovements()
          ..produtoId = produtoId
          ..inicio = inicio
          ..fim = fim,
        from: stockMovementsProvider,
        name: r'stockMovementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stockMovementsHash,
        dependencies: StockMovementsFamily._dependencies,
        allTransitiveDependencies:
            StockMovementsFamily._allTransitiveDependencies,
        produtoId: produtoId,
        inicio: inicio,
        fim: fim,
      );

  StockMovementsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.produtoId,
    required this.inicio,
    required this.fim,
  }) : super.internal();

  final int? produtoId;
  final DateTime? inicio;
  final DateTime? fim;

  @override
  FutureOr<List<EstoqueMovimentacao>> runNotifierBuild(
    covariant StockMovements notifier,
  ) {
    return notifier.build(produtoId: produtoId, inicio: inicio, fim: fim);
  }

  @override
  Override overrideWith(StockMovements Function() create) {
    return ProviderOverride(
      origin: this,
      override: StockMovementsProvider._internal(
        () => create()
          ..produtoId = produtoId
          ..inicio = inicio
          ..fim = fim,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        produtoId: produtoId,
        inicio: inicio,
        fim: fim,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StockMovements,
    List<EstoqueMovimentacao>
  >
  createElement() {
    return _StockMovementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StockMovementsProvider &&
        other.produtoId == produtoId &&
        other.inicio == inicio &&
        other.fim == fim;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, produtoId.hashCode);
    hash = _SystemHash.combine(hash, inicio.hashCode);
    hash = _SystemHash.combine(hash, fim.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StockMovementsRef
    on AutoDisposeAsyncNotifierProviderRef<List<EstoqueMovimentacao>> {
  /// The parameter `produtoId` of this provider.
  int? get produtoId;

  /// The parameter `inicio` of this provider.
  DateTime? get inicio;

  /// The parameter `fim` of this provider.
  DateTime? get fim;
}

class _StockMovementsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StockMovements,
          List<EstoqueMovimentacao>
        >
    with StockMovementsRef {
  _StockMovementsProviderElement(super.provider);

  @override
  int? get produtoId => (origin as StockMovementsProvider).produtoId;
  @override
  DateTime? get inicio => (origin as StockMovementsProvider).inicio;
  @override
  DateTime? get fim => (origin as StockMovementsProvider).fim;
}

String _$inventoriesHash() => r'0357ab91c29b10527b16e905b1d7d8682754d764';

/// See also [Inventories].
@ProviderFor(Inventories)
final inventoriesProvider =
    AutoDisposeAsyncNotifierProvider<Inventories, List<Inventario>>.internal(
      Inventories.new,
      name: r'inventoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inventoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Inventories = AutoDisposeAsyncNotifier<List<Inventario>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
