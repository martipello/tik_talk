// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historySessionStoreHash() =>
    r'ccd01786e0d9a532efa81446f99a1e260048369b';

/// See also [historySessionStore].
@ProviderFor(historySessionStore)
final historySessionStoreProvider =
    AutoDisposeProvider<HistorySessionStore>.internal(
      historySessionStore,
      name: r'historySessionStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historySessionStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistorySessionStoreRef = AutoDisposeProviderRef<HistorySessionStore>;
String _$historyNotifierHash() => r'36df033a010b25c83c70b13053dd00712a7b5b1d';

/// See also [HistoryNotifier].
@ProviderFor(HistoryNotifier)
final historyNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      HistoryNotifier,
      List<TimerSession>
    >.internal(
      HistoryNotifier.new,
      name: r'historyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoryNotifier = AutoDisposeAsyncNotifier<List<TimerSession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
