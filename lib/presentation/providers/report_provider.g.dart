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

String _$stockReportHash() => r'4e85b257bac399e08004bd0757e325dee582cfaf';

/// See also [StockReport].
@ProviderFor(StockReport)
final stockReportProvider =
    AutoDisposeAsyncNotifierProvider<StockReport, RelatorioEstoque>.internal(
      StockReport.new,
      name: r'stockReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stockReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StockReport = AutoDisposeAsyncNotifier<RelatorioEstoque>;
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
String _$dreReportHash() => r'7f930c99ba78ae399de70bdbed2d6839cda74481';

abstract class _$DreReport
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final int? mes;
  late final int? ano;

  FutureOr<Map<String, dynamic>> build({int? mes, int? ano});
}

/// See also [DreReport].
@ProviderFor(DreReport)
const dreReportProvider = DreReportFamily();

/// See also [DreReport].
class DreReportFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [DreReport].
  const DreReportFamily();

  /// See also [DreReport].
  DreReportProvider call({int? mes, int? ano}) {
    return DreReportProvider(mes: mes, ano: ano);
  }

  @override
  DreReportProvider getProviderOverride(covariant DreReportProvider provider) {
    return call(mes: provider.mes, ano: provider.ano);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dreReportProvider';
}

/// See also [DreReport].
class DreReportProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<DreReport, Map<String, dynamic>> {
  /// See also [DreReport].
  DreReportProvider({int? mes, int? ano})
    : this._internal(
        () => DreReport()
          ..mes = mes
          ..ano = ano,
        from: dreReportProvider,
        name: r'dreReportProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dreReportHash,
        dependencies: DreReportFamily._dependencies,
        allTransitiveDependencies: DreReportFamily._allTransitiveDependencies,
        mes: mes,
        ano: ano,
      );

  DreReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mes,
    required this.ano,
  }) : super.internal();

  final int? mes;
  final int? ano;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant DreReport notifier,
  ) {
    return notifier.build(mes: mes, ano: ano);
  }

  @override
  Override overrideWith(DreReport Function() create) {
    return ProviderOverride(
      origin: this,
      override: DreReportProvider._internal(
        () => create()
          ..mes = mes
          ..ano = ano,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mes: mes,
        ano: ano,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DreReport, Map<String, dynamic>>
  createElement() {
    return _DreReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DreReportProvider && other.mes == mes && other.ano == ano;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mes.hashCode);
    hash = _SystemHash.combine(hash, ano.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DreReportRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `mes` of this provider.
  int? get mes;

  /// The parameter `ano` of this provider.
  int? get ano;
}

class _DreReportProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<DreReport, Map<String, dynamic>>
    with DreReportRef {
  _DreReportProviderElement(super.provider);

  @override
  int? get mes => (origin as DreReportProvider).mes;
  @override
  int? get ano => (origin as DreReportProvider).ano;
}

String _$inadimplenciaReportHash() =>
    r'4830471950a7eab51c5ba454bfc469da5339aac9';

/// See also [InadimplenciaReport].
@ProviderFor(InadimplenciaReport)
final inadimplenciaReportProvider =
    AutoDisposeAsyncNotifierProvider<
      InadimplenciaReport,
      Map<String, dynamic>
    >.internal(
      InadimplenciaReport.new,
      name: r'inadimplenciaReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inadimplenciaReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InadimplenciaReport = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$curvaABCReportHash() => r'04fb3f1a1d7bc1773babb43867e3b31f78f99d08';

/// See also [CurvaABCReport].
@ProviderFor(CurvaABCReport)
final curvaABCReportProvider =
    AutoDisposeAsyncNotifierProvider<
      CurvaABCReport,
      Map<String, dynamic>
    >.internal(
      CurvaABCReport.new,
      name: r'curvaABCReportProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$curvaABCReportHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurvaABCReport = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$comissoesReportHash() => r'1df892c939b29b49f081bec4e77377ffd7201f74';

abstract class _$ComissoesReport
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final int? mes;
  late final int? ano;

  FutureOr<Map<String, dynamic>> build({int? mes, int? ano});
}

/// See also [ComissoesReport].
@ProviderFor(ComissoesReport)
const comissoesReportProvider = ComissoesReportFamily();

/// See also [ComissoesReport].
class ComissoesReportFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [ComissoesReport].
  const ComissoesReportFamily();

  /// See also [ComissoesReport].
  ComissoesReportProvider call({int? mes, int? ano}) {
    return ComissoesReportProvider(mes: mes, ano: ano);
  }

  @override
  ComissoesReportProvider getProviderOverride(
    covariant ComissoesReportProvider provider,
  ) {
    return call(mes: provider.mes, ano: provider.ano);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'comissoesReportProvider';
}

/// See also [ComissoesReport].
class ComissoesReportProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ComissoesReport,
          Map<String, dynamic>
        > {
  /// See also [ComissoesReport].
  ComissoesReportProvider({int? mes, int? ano})
    : this._internal(
        () => ComissoesReport()
          ..mes = mes
          ..ano = ano,
        from: comissoesReportProvider,
        name: r'comissoesReportProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$comissoesReportHash,
        dependencies: ComissoesReportFamily._dependencies,
        allTransitiveDependencies:
            ComissoesReportFamily._allTransitiveDependencies,
        mes: mes,
        ano: ano,
      );

  ComissoesReportProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mes,
    required this.ano,
  }) : super.internal();

  final int? mes;
  final int? ano;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant ComissoesReport notifier,
  ) {
    return notifier.build(mes: mes, ano: ano);
  }

  @override
  Override overrideWith(ComissoesReport Function() create) {
    return ProviderOverride(
      origin: this,
      override: ComissoesReportProvider._internal(
        () => create()
          ..mes = mes
          ..ano = ano,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mes: mes,
        ano: ano,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ComissoesReport, Map<String, dynamic>>
  createElement() {
    return _ComissoesReportProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ComissoesReportProvider &&
        other.mes == mes &&
        other.ano == ano;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mes.hashCode);
    hash = _SystemHash.combine(hash, ano.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ComissoesReportRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `mes` of this provider.
  int? get mes;

  /// The parameter `ano` of this provider.
  int? get ano;
}

class _ComissoesReportProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ComissoesReport,
          Map<String, dynamic>
        >
    with ComissoesReportRef {
  _ComissoesReportProviderElement(super.provider);

  @override
  int? get mes => (origin as ComissoesReportProvider).mes;
  @override
  int? get ano => (origin as ComissoesReportProvider).ano;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
