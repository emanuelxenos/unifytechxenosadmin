// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountsPayableHash() => r'0dd3b3917fce5933b4477709f0a3ce6be02295ff';

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
    r'04400aa72b7a137ae901715927e3455787f6a0b1';

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
String _$cashFlowHash() => r'272e20dc6cecb40a95147183b6909cf8e6083323';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
