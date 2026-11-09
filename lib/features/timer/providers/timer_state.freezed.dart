// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  Duration get elapsed => throw _privateConstructorUsedError;
  List<Lap> get laps => throw _privateConstructorUsedError;
  int get countdownSecondsRemaining => throw _privateConstructorUsedError;
  double get countdownDialValue => throw _privateConstructorUsedError;
  String? get label =>
      throw _privateConstructorUsedError; // Set when this state originated from resuming a saved history entry, so
  // stop() can update that entry in place instead of inserting a second
  // one for the same session.
  int? get resumedSessionId => throw _privateConstructorUsedError;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
    TimerState value,
    $Res Function(TimerState) then,
  ) = _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call({
    TimerStatus status,
    Duration elapsed,
    List<Lap> laps,
    int countdownSecondsRemaining,
    double countdownDialValue,
    String? label,
    int? resumedSessionId,
  });
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? laps = null,
    Object? countdownSecondsRemaining = null,
    Object? countdownDialValue = null,
    Object? label = freezed,
    Object? resumedSessionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TimerStatus,
            elapsed: null == elapsed
                ? _value.elapsed
                : elapsed // ignore: cast_nullable_to_non_nullable
                      as Duration,
            laps: null == laps
                ? _value.laps
                : laps // ignore: cast_nullable_to_non_nullable
                      as List<Lap>,
            countdownSecondsRemaining: null == countdownSecondsRemaining
                ? _value.countdownSecondsRemaining
                : countdownSecondsRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
            countdownDialValue: null == countdownDialValue
                ? _value.countdownDialValue
                : countdownDialValue // ignore: cast_nullable_to_non_nullable
                      as double,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            resumedSessionId: freezed == resumedSessionId
                ? _value.resumedSessionId
                : resumedSessionId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
    _$TimerStateImpl value,
    $Res Function(_$TimerStateImpl) then,
  ) = __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    TimerStatus status,
    Duration elapsed,
    List<Lap> laps,
    int countdownSecondsRemaining,
    double countdownDialValue,
    String? label,
    int? resumedSessionId,
  });
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
    _$TimerStateImpl _value,
    $Res Function(_$TimerStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? elapsed = null,
    Object? laps = null,
    Object? countdownSecondsRemaining = null,
    Object? countdownDialValue = null,
    Object? label = freezed,
    Object? resumedSessionId = freezed,
  }) {
    return _then(
      _$TimerStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TimerStatus,
        elapsed: null == elapsed
            ? _value.elapsed
            : elapsed // ignore: cast_nullable_to_non_nullable
                  as Duration,
        laps: null == laps
            ? _value._laps
            : laps // ignore: cast_nullable_to_non_nullable
                  as List<Lap>,
        countdownSecondsRemaining: null == countdownSecondsRemaining
            ? _value.countdownSecondsRemaining
            : countdownSecondsRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
        countdownDialValue: null == countdownDialValue
            ? _value.countdownDialValue
            : countdownDialValue // ignore: cast_nullable_to_non_nullable
                  as double,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        resumedSessionId: freezed == resumedSessionId
            ? _value.resumedSessionId
            : resumedSessionId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$TimerStateImpl implements _TimerState {
  const _$TimerStateImpl({
    required this.status,
    required this.elapsed,
    required final List<Lap> laps,
    required this.countdownSecondsRemaining,
    required this.countdownDialValue,
    this.label,
    this.resumedSessionId,
  }) : _laps = laps;

  @override
  final TimerStatus status;
  @override
  final Duration elapsed;
  final List<Lap> _laps;
  @override
  List<Lap> get laps {
    if (_laps is EqualUnmodifiableListView) return _laps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_laps);
  }

  @override
  final int countdownSecondsRemaining;
  @override
  final double countdownDialValue;
  @override
  final String? label;
  // Set when this state originated from resuming a saved history entry, so
  // stop() can update that entry in place instead of inserting a second
  // one for the same session.
  @override
  final int? resumedSessionId;

  @override
  String toString() {
    return 'TimerState(status: $status, elapsed: $elapsed, laps: $laps, countdownSecondsRemaining: $countdownSecondsRemaining, countdownDialValue: $countdownDialValue, label: $label, resumedSessionId: $resumedSessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            const DeepCollectionEquality().equals(other._laps, _laps) &&
            (identical(
                  other.countdownSecondsRemaining,
                  countdownSecondsRemaining,
                ) ||
                other.countdownSecondsRemaining == countdownSecondsRemaining) &&
            (identical(other.countdownDialValue, countdownDialValue) ||
                other.countdownDialValue == countdownDialValue) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.resumedSessionId, resumedSessionId) ||
                other.resumedSessionId == resumedSessionId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    elapsed,
    const DeepCollectionEquality().hash(_laps),
    countdownSecondsRemaining,
    countdownDialValue,
    label,
    resumedSessionId,
  );

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState implements TimerState {
  const factory _TimerState({
    required final TimerStatus status,
    required final Duration elapsed,
    required final List<Lap> laps,
    required final int countdownSecondsRemaining,
    required final double countdownDialValue,
    final String? label,
    final int? resumedSessionId,
  }) = _$TimerStateImpl;

  @override
  TimerStatus get status;
  @override
  Duration get elapsed;
  @override
  List<Lap> get laps;
  @override
  int get countdownSecondsRemaining;
  @override
  double get countdownDialValue;
  @override
  String? get label; // Set when this state originated from resuming a saved history entry, so
  // stop() can update that entry in place instead of inserting a second
  // one for the same session.
  @override
  int? get resumedSessionId;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
