// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesReportDayHash() => r'6bc65b4694c6cfcdd43b80eb312a089eaaeaa3a8';

/// See also [SalesReportDay].
@ProviderFor(SalesReportDay)
final salesReportDayProvider =
    AutoDisposeAsyncNotifierProvider<
      SalesReportDay,
      Map<String, dynamic>
    >.internal(
      SalesReportDay.new,
      name: r'salesReportDayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$salesReportDayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SalesReportDay = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$salesReportMonthHash() => r'0970dd5b74cd3f1671333aa55331b1ae2e89504a';

/// See also [SalesReportMonth].
@ProviderFor(SalesReportMonth)
final salesReportMonthProvider =
    AutoDisposeAsyncNotifierProvider<
      SalesReportMonth,
      Map<String, dynamic>
    >.internal(
      SalesReportMonth.new,
      name: r'salesReportMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$salesReportMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SalesReportMonth = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$bestSellersHash() => r'b9a01334f32101f524a7c6f47b3c66b4f392623c';

/// See also [BestSellers].
@ProviderFor(BestSellers)
final bestSellersProvider =
    AutoDisposeAsyncNotifierProvider<
      BestSellers,
      List<Map<String, dynamic>>
    >.internal(
      BestSellers.new,
      name: r'bestSellersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bestSellersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BestSellers = AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
String _$salesReportPeriodHash() => r'6e3d0145dd6cf7215067aa6f58f1cab1ec094870';

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

abstract class _$SalesReportPeriod
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final String dataInicio;
  late final String dataFim;

  FutureOr<Map<String, dynamic>> build(String dataInicio, String dataFim);
}

/// See also [SalesReportPeriod].
@ProviderFor(SalesReportPeriod)
const salesReportPeriodProvider = SalesReportPeriodFamily();

/// See also [SalesReportPeriod].
class SalesReportPeriodFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [SalesReportPeriod].
  const SalesReportPeriodFamily();

  /// See also [SalesReportPeriod].
  SalesReportPeriodProvider call(String dataInicio, String dataFim) {
    return SalesReportPeriodProvider(dataInicio, dataFim);
  }

  @override
  SalesReportPeriodProvider getProviderOverride(
    covariant SalesReportPeriodProvider provider,
  ) {
    return call(provider.dataInicio, provider.dataFim);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'salesReportPeriodProvider';
}

/// See also [SalesReportPeriod].
class SalesReportPeriodProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SalesReportPeriod,
          Map<String, dynamic>
        > {
  /// See also [SalesReportPeriod].
  SalesReportPeriodProvider(String dataInicio, String dataFim)
    : this._internal(
        () => SalesReportPeriod()
          ..dataInicio = dataInicio
          ..dataFim = dataFim,
        from: salesReportPeriodProvider,
        name: r'salesReportPeriodProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$salesReportPeriodHash,
        dependencies: SalesReportPeriodFamily._dependencies,
        allTransitiveDependencies:
            SalesReportPeriodFamily._allTransitiveDependencies,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );

  SalesReportPeriodProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dataInicio,
    required this.dataFim,
  }) : super.internal();

  final String dataInicio;
  final String dataFim;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant SalesReportPeriod notifier,
  ) {
    return notifier.build(dataInicio, dataFim);
  }

  @override
  Override overrideWith(SalesReportPeriod Function() create) {
    return ProviderOverride(
      origin: this,
      override: SalesReportPeriodProvider._internal(
        () => create()
          ..dataInicio = dataInicio
          ..dataFim = dataFim,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dataInicio: dataInicio,
        dataFim: dataFim,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    SalesReportPeriod,
    Map<String, dynamic>
  >
  createElement() {
    return _SalesReportPeriodProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesReportPeriodProvider &&
        other.dataInicio == dataInicio &&
        other.dataFim == dataFim;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dataInicio.hashCode);
    hash = _SystemHash.combine(hash, dataFim.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SalesReportPeriodRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `dataInicio` of this provider.
  String get dataInicio;

  /// The parameter `dataFim` of this provider.
  String get dataFim;
}

class _SalesReportPeriodProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SalesReportPeriod,
          Map<String, dynamic>
        >
    with SalesReportPeriodRef {
  _SalesReportPeriodProviderElement(super.provider);

  @override
  String get dataInicio => (origin as SalesReportPeriodProvider).dataInicio;
  @override
  String get dataFim => (origin as SalesReportPeriodProvider).dataFim;
}

String _$stockReportHash() => r'e6bedbfedb66cc8f362ba6e2119b2b999deb1834';

/// See also [StockReport].
@ProviderFor(StockReport)
final stockReportProvider =
    AutoDisposeAsyncNotifierProvider<
      StockReport,
      Map<String, dynamic>
    >.internal(
      StockReport.new,
      name: r'stockReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stockReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StockReport = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$financeReportHash() => r'7086e7036f52f7bcc389efb96800a8f3e8f4f691';

/// See also [FinanceReport].
@ProviderFor(FinanceReport)
final financeReportProvider =
    AutoDisposeAsyncNotifierProvider<
      FinanceReport,
      Map<String, dynamic>
    >.internal(
      FinanceReport.new,
      name: r'financeReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$financeReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FinanceReport = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
