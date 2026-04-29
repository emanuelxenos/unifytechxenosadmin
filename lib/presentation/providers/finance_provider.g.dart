// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountsPayableHash() => r'599f8dcdf2948a142848b08a3cf533728f350f40';

/// See also [AccountsPayable].
@ProviderFor(AccountsPayable)
final accountsPayableProvider =
    AutoDisposeAsyncNotifierProvider<
      AccountsPayable,
      List<ContaPagar>
    >.internal(
      AccountsPayable.new,
      name: r'accountsPayableProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$accountsPayableHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AccountsPayable = AutoDisposeAsyncNotifier<List<ContaPagar>>;
String _$accountsReceivableHash() =>
    r'006f1c62e237d5ce189da8f4d81def1eda37ee03';

/// See also [AccountsReceivable].
@ProviderFor(AccountsReceivable)
final accountsReceivableProvider =
    AutoDisposeAsyncNotifierProvider<
      AccountsReceivable,
      List<ContaReceber>
    >.internal(
      AccountsReceivable.new,
      name: r'accountsReceivableProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$accountsReceivableHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AccountsReceivable = AutoDisposeAsyncNotifier<List<ContaReceber>>;
String _$cashFlowHash() => r'f08197b3368a9fbb6f2a0e3fcf2f1f8eaa50e513';

/// See also [CashFlow].
@ProviderFor(CashFlow)
final cashFlowProvider =
    AutoDisposeAsyncNotifierProvider<CashFlow, FluxoCaixaResponse>.internal(
      CashFlow.new,
      name: r'cashFlowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashFlowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CashFlow = AutoDisposeAsyncNotifier<FluxoCaixaResponse>;
String _$financialFiltersHash() => r'bee4da4f953cc0d05ff63ca39598a779d361a140';

/// See also [FinancialFilters].
@ProviderFor(FinancialFilters)
final financialFiltersProvider =
    AutoDisposeNotifierProvider<
      FinancialFilters,
      ({DateTime? start, DateTime? end})
    >.internal(
      FinancialFilters.new,
      name: r'financialFiltersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$financialFiltersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FinancialFilters =
    AutoDisposeNotifier<({DateTime? start, DateTime? end})>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
